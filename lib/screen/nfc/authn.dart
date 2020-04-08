import 'dart:async';
import 'dart:io';

//import 'package:connectivity/connectivity.dart';
import 'package:dmrtd/dmrtd.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dmrtd/extensions.dart';
import 'package:eosio_passid_mobile_app/screen/customChip.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:passid/src/proto/proto_challenge.dart';
import "package:eosio_passid_mobile_app/screen/nfc/passport_scanner.dart";
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:eosio_passid_mobile_app/screen/nfc/uie/efdg1.dart';
import 'package:passid/src/authn_data.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
//import 'package:open_settings/open_settings.dart';
import 'package:eosio_passid_mobile_app/screen/customAlert.dart';
import 'package:eosio_passid_mobile_app/utils/structure.dart';
import 'package:passid/passid.dart';
import 'package:logging/logging.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import 'package:eosio_passid_mobile_app/screen/customBottomPicker.dart';

Map AUTHENTICATOR_ACTIONS = {
  "ATTESTAION_REQUEST": {"NAME":"Attestation", "DATA": ["Country (SOD)", "Passport Public Key (DG15)", "Passport Signature"]},
  "PERSONAL_INFORMATION_REQUEST": {"NAME":"Personal Information", "DATA": ["Personal Information (DG1))", "Passport Signature"]},
  "PERSONAL_INFORMATION_REQUEST_FALSIFIED": {"NAME":"Personal Information - Falsified", "DATA": ["Personal Information (DG1)", "Passport Signature)"]},
  "LOGIN": {"NAME":"Login", "DATA": ["Passport Signature"]},
  };

class ServerSecurityContext  {
  static SecurityContext _ctx;

  /// 'Globally' init ctx using server certificate (.cer) bytes.
  /// [servCertBytes] should be single certificate because sha1
  /// is calculated over these bytes and checked against sha1 of
  /// certificate in _certificateCheck.
  static init(List<int> servCertBytes) {
    _ctx = SecurityContext();
    _ctx.setTrustedCertificatesBytes(servCertBytes);
  }

  static HttpClient getHttpClient({Duration timeout}) {
    final c = HttpClient(context: _ctx);
    if(timeout != null) {
      c.connectionTimeout = timeout;
    }
    return c;
  }
}

enum AuthnAction { register, login }


class Authn extends StatefulWidget {
  String _selectedAction = "ATTESTAION_REQUEST";

  Authn({Key key});

  _AuthnState createState() => _AuthnState();
}

class _AuthnState extends State<Authn> {
  PassIdClient _client;
  final _log = Logger('authn.screen');

  //ProtoChallenge _challenge;

  var _authnData = Completer<AuthnData>();

  _AuthnState()
  {
    print("start of test-test");

    print("end of test-test");
  }

  Future<bool> _handleConnectionError(final SocketException e) async {
    String title;
    String msg;
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none ||
        !await testConnection()) {
      title = 'No Internet connection';
      msg   = 'Internet connection is required in order to '
          "${AuthnAction.register == AuthnAction.register ? "sign up" : "login"}.";
    }
    else {
      //settingsAction = () => _settingsButton.onPressed();
      title = 'Connection error';
      msg   = 'Failed to connect to server.\n'
          'Check server connection settings.';
    }

    return showAlert<bool>(context,
        Text(title),
        Text(msg),
        [
          FlatButton(
              child: Text('OK',
                  style: TextStyle(
                      color: Theme.of(context).errorColor,
                      fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pop(context, false)
          )
        ]
    );
  }

  Future<bool> showDG1(final EfDG1 dg1) async{
   return showAlert<bool>(context,
       Text('DG1'),

       Container(
           height: MediaQuery.of(context).size.height - 50,
           child: Padding(
               padding: EdgeInsets.all(16.0),
               child: Column(children: <Widget>[
                 const SizedBox(height: 10),
                 const SizedBox(height: 20),
                 SingleChildScrollView(
                     child: Card(
                         child: Padding(
                             padding: EdgeInsets.all(16.0),
                             child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.center,
                                 children: <Widget>[
                                   Text(
                                     'Passport Data',
                                     style: TextStyle(
                                         fontWeight: FontWeight.bold,
                                         fontSize: 18),
                                   ),
                                   const SizedBox(height: 5),
                                   Row(children: <Widget>[
                                     Expanded(
                                         child: Text(
                                           'Passport type:',
                                           style: TextStyle(fontSize: 16),
                                         )),
                                     Expanded(
                                         child: Text(dg1.mrz.documentCode,
                                             style: TextStyle(fontSize: 16)))
                                   ]),
                                   Row(
                                       mainAxisAlignment:
                                       MainAxisAlignment.spaceBetween,
                                       children: <Widget>[
                                         Expanded(
                                             child: Text('Passport no.:',
                                                 style: TextStyle(fontSize: 16))),
                                         Expanded(
                                             child: Text(dg1.mrz.documentNumber,
                                                 style: TextStyle(fontSize: 16))),
                                       ]),
                                   Row(children: <Widget>[
                                     Expanded(
                                         child: Text('Date of Expiry:',
                                             style: TextStyle(fontSize: 16))),
                                     Expanded(
                                         child: Text(
                                                 dg1.mrz.dateOfExpiry.toIso8601String(),
                                             style: TextStyle(fontSize: 16)))
                                   ]),
                                   Row(children: <Widget>[
                                     Expanded(
                                         child: Text('Issuing Country:',
                                             style: TextStyle(fontSize: 16))),
                                     Expanded(
                                         child: Text(dg1.mrz.country,
                                             style: TextStyle(fontSize: 16)))
                                   ]),
                                   const SizedBox(height: 30),
                                   Text(
                                     'Personal Data',
                                     style: TextStyle(
                                         fontWeight: FontWeight.bold,
                                         fontSize: 18),
                                   ),
                                   const SizedBox(height: 5),
                                   Row(children: <Widget>[
                                     Expanded(
                                         child: Text('Name:',
                                             style: TextStyle(fontSize: 16))),
                                     Expanded(
                                         child: Text(dg1.mrz.firstName,
                                             style: TextStyle(fontSize: 16))),
                                   ]),
                                   Row(
                                     children: <Widget>[
                                       Expanded(
                                           child: Text('Last Name',
                                               style: TextStyle(fontSize: 16))),
                                       Expanded(
                                           child: Text(
                                               dg1.mrz.lastName,
                                               style: TextStyle(fontSize: 16))),
                                     ],
                                   ),
                                   Row(children: <Widget>[
                                     Expanded(
                                         child: Text('Date of Birth:',
                                             style: TextStyle(fontSize: 16))),
                                     Expanded(
                                         child: Text(dg1.mrz.dateOfBirth.toIso8601String(),
                                             style: TextStyle(fontSize: 16))),
                                   ]),
                                   Row(children: <Widget>[
                                     Expanded(
                                         child: Text('Sex:',
                                             style: TextStyle(fontSize: 16))),
                                     Expanded(
                                       child: Text(
                                           dg1.mrz.sex.isEmpty
                                               ? '/'
                                               : dg1.mrz.sex == 'M'
                                               ? 'Male'
                                               : 'Female',
                                           style: TextStyle(fontSize: 16)),
                                     )
                                   ]),
                                   Row(children: <Widget>[
                                     Expanded(
                                         child: Text('Nationality:',
                                             style: TextStyle(fontSize: 16))),
                                     Expanded(
                                         child: Text(dg1.mrz.country,
                                             style: TextStyle(fontSize: 16))),
                                   ]),
                                   Row(children: <Widget>[
                                     Text('Additional Data:',
                                         style: TextStyle(fontSize: 16)),
                                     Spacer(),
                                     Text(dg1.mrz.optionalData,
                                         style: TextStyle(fontSize: 16)),
                                     Spacer()
                                   ]),
                                 ])))),
                 Spacer(flex: 60),
                 /*Wrap(
                     direction: Axis.horizontal,
                     runSpacing: 10,
                     spacing: 10,
                     children: <Widget>[...actions])*/
               ]))),


       [
         FlatButton(
             child: const Text(
               'OK',
               style: TextStyle(fontWeight: FontWeight.bold),
             ),
             onPressed: () => Navigator.pop(context, true)
         )
       ]
   );
 }

  Future<bool> _handleDG1Request(final EfDG1 dg1) async {
    return showAlert<bool>(context,
        Text('Data Required'),
        Text('Server requested your personal data from passport in order to login.\n\nSend personal data to server?'),
        [
          FlatButton(
              child: Text('Cancel',
                  style: TextStyle(
                      color: Theme.of(context).errorColor,
                      fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pop(context, false)
          ),
          FlatButton(
              child: const Text(
                'View',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                showDG1(dg1);
                /*return Navigator.push(
                              context,
                              CupertinoPageRoute (
                                  builder: (context) => EfDG1View(dg1), fullscreenDialog: true),
                            */

              }),
          FlatButton(
              child: const Text(
                'Send',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pop(context, true)
          )
        ]
    );
  }


  Future<AuthnData>  _getAuthnData(final ProtoChallenge challenge, AuthnAction action, String passportID, DateTime birthDate, DateTime validUntil) async {
    //_challenge = challenge;
    scanPassport(challenge, action,  passportID, birthDate, validUntil);
    return _authnData.future;
  }


  Future<void> scanPassport(ProtoChallenge challenge, AuthnAction action, String passportID, DateTime birthDate, DateTime validUntilDate) async {
    assert(challenge != null);
    try {
      final dbaKeys = DBAKeys(passportID, birthDate, validUntilDate);
      final data = await PassportScanner(
          context: context,
          challenge: challenge,
          action:  action
      ).scan(dbaKeys);
      Storage storage = Storage();
      await storage.getDBAkeyStorage().setDBAKeys(dbaKeys);
      //await Preferences.setDBAKeys(dbaKeys);  // Save MRZ data
      _authnData.complete(data);
    } catch(e) {} // ignore: empty_catches
    finally {
      setState(() {
        //_isScanningMrtd = false;
      });
    }
  }


  String checkValuesInStorage() {
    String missingValuesText = '';
    Storage storage = Storage();
    StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0);
    if (storageStepEnterAccount.isUnlocked == false)
      missingValuesText +=  "Account name (Step 'Enter account') is not valid.\n";

    StepDataScan storageStepScan = storage.getStorageData(1);
    if (storageStepScan.documentID == null)
      missingValuesText += "Passport Number(Step 'Scan') is not valid.\n";
    if (storageStepScan.birth == null)
      missingValuesText += "Date of birth (Step 'Scan') is not valid.\n";
    if (storageStepScan.validUntil == null)
      missingValuesText += "Date of Expiratio (Step 'Scan') is not valid.\n";

    return missingValuesText;
  }

  void startAction(BuildContext context, AuthnAction action, [bool sendDG1 = false]) async {
    Storage storage = Storage();
    String checkedValues = checkValuesInStorage();
    if (checkedValues != "") {
      showAlert<bool>(context,
          Text('Warning'),
          Text(checkedValues +
              "Update values before passport validation."),
          [
            FlatButton(
                child: const Text(
                  'OK',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => Navigator.pop(context, true)
            )
          ]
      );
      return;
    }
    try {
      final httpClient = ServerSecurityContext
          .getHttpClient(timeout: Duration(seconds:storage.storageServer.timeoutInSeconds))
        ..badCertificateCallback = badCertificateHostCheck;

      _client = PassIdClient(Uri.parse(storage.storageServer.toString()), httpClient: httpClient);
      _client.onConnectionError  = _handleConnectionError;
      _client.onDG1FileRequested = _handleDG1Request;

      if (action == AuthnAction.register)
        await _client.register((challenge) async {
          StepDataScan storageStepScan = storage.getStorageData(1);
          return await _getAuthnData(challenge, AuthnAction.register, storageStepScan.documentID, storageStepScan.birth, storageStepScan.validUntil).then((data) {
            return data;
          });
        }
        );
      else
        await _client.login((challenge) async {
          StepDataScan storageStepScan = storage.getStorageData(1);
          return await _getAuthnData(challenge, AuthnAction.login, storageStepScan.documentID, storageStepScan.birth, storageStepScan.validUntil).then((data) {
            return data;
          });
        },
        sendEfDG1: sendDG1
        );

      final srvMsgGreeting = await _client.requestGreeting();
      showAlert<bool>(context,
          Text('Greetings from server'),
          Text(srvMsgGreeting),
          [
            FlatButton(
                child: Text('OK',
                    style: TextStyle(
                        color: Theme.of(context).errorColor,
                        fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.pop(context, false)
            ),
          ]
      );
      _authnData = Completer<AuthnData>();
      storage.getDBAkeyStorage().init();

    } catch(e) {
      String alertTitle;
      String alertMsg;
      if (e is SocketException) {} // should be already handled through _handleConnectionError callback
      if(e is PassIdError) {
        if(!e.isDG1Required()) { // DG1 required error should be handled through _handleDG1Request callback
          _log.error('An unhandled passId exception, closing this screen.\n error=$e');
          alertTitle = 'PassID Error';
          switch(e.code){
            case 401: alertMsg = 'Authorization failed!'; break;
          //case 404: // TODO: parse message and translate it to system language
            case 406: {
              alertMsg = 'Passport verification failed!';
              final msg = e.message.toLowerCase();
              if(msg.contains('invalid dg1 file')) {
                alertMsg = 'Server refused to accept sent personal data!';
              }
              else if(msg.contains('invalid dg15 file')) {
                alertMsg = "Server refused to accept passport's public key!";
              }
            } break;
            case 409: alertMsg = 'Account already exists!'; break;
            case 412: alertMsg = 'Passport trust chain verification failed!'; break;
            case 498: {
              final msg = e.message.toLowerCase();
              if(msg.contains('account has expired')) {
                alertMsg = 'Account has expired, please register again!';
                break;
              }
            } continue dflt;
            dflt:
            default:
              alertMsg = 'Server returned error:\n\n${e.message}';
          }
        }
      }
      else {
        _log.error('An unhandled exception was encountered, closing this screen.\n error=$e');
        alertTitle = 'Error';
        alertMsg = (e is Exception)
            ? e.toString().split('Exception: ').first
            : 'An unknown error has occurred.';
      }

      // Show alert dialog
      if(alertMsg != null && alertTitle != null) {
        await showAlert(context, Text(alertTitle), Text(alertMsg), [
          FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                    color: Theme.of(context).errorColor,
                    fontWeight: FontWeight.bold),
              ))
        ]);
      }
      _authnData = Completer<AuthnData>();
    }

  }

  void selectNetwork(var context) {
    BottomPickerStructure bps = BottomPickerStructure();
    bps.importActionTypesList(AUTHENTICATOR_ACTIONS, "ATTESTAION_REQUEST",
        "Select validation", "Please select type of validation");
    CustomBottomPickerState cbps = CustomBottomPickerState(structure: bps);
    cbps.showPicker(context,
        //callback function to manage user click action on selection
            (BottomPickerElement returnedItem){
              setState(() {
                widget._selectedAction = returnedItem.key;
              });
        }
    );
  }

  Widget selectModeWithTile(var context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
      title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Request',
              style: TextStyle(fontSize: AndroidThemeST().getValues().themeValues["STEPPER"]["STEP_TAP"]["SIZE_TEXT"]),
            ),
            Text(
                AUTHENTICATOR_ACTIONS[widget._selectedAction]['NAME'],
                style:
                TextStyle(fontSize: AndroidThemeST().getValues().themeValues["STEPPER"]["STEP_TAP"]["SIZE_TEXT"],
                    color:  AndroidThemeST().getValues().themeValues["TILE_BAR"]["COLOR_TEXT"]))
          ]),
      //subtitle: Text("to see what is going to be sent"),
      trailing: Icon(Icons.expand_more),
      onTap: () => selectNetwork(context),
    );
  }
  Widget dataDescription(var context) {
    return Container(
      alignment: Alignment.centerLeft,
        child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
              Container(child: Text('Data Sent', style: TextStyle(/*fontWeight: FontWeight.bold,*/ fontSize: AndroidThemeST().getValues().themeValues["STEPPER"]["STEP_TAP"]["SIZE_TEXT"])), margin: EdgeInsets.only(bottom: 10.0)),
              for (var item in AUTHENTICATOR_ACTIONS[widget._selectedAction]["DATA"])
                Container(child:
                  Text('  • ' +item, style:
                        TextStyle(fontSize: AndroidThemeST().getValues().themeValues["STEPPER"]["STEP_TAP"]["SIZE_TEXT"] - 2,
                                  color: AndroidThemeST().getValues().themeValues["STEPPER"]["STEP_TAP"]["COLOR_TEXT"])),
                          margin: EdgeInsets.only(left: 0.0))
          //AndroidThemeST().getValues().themeValues["STEPPER"]["STEPPER_MANIPULATOR"]["COLOR_TEXT"])
          ]
          ));
  }
  Widget buttonScan(var context){
    return Row(
      //mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[Padding(padding: EdgeInsets.only(top: 40), child:
      PlatformButton (
        child:Text('Attest and Send',style: TextStyle(color: Colors.white)),
        onPressed: () {
            if (widget._selectedAction == "ATTESTAION_REQUEST")
                startAction(context, AuthnAction.register);
            else if (widget._selectedAction == "PERSONAL_INFORMATION_REQUEST")
              startAction(context, AuthnAction.login, true);
            else if (widget._selectedAction == "PERSONAL_INFORMATION_REQUEST_FALSIFIED")
              startAction(context, AuthnAction.login, true);
            else if (widget._selectedAction == "LOGIN")
              startAction(context, AuthnAction.login);

        },/**/
      ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

      return Container(
          child: Column(children: <Widget>[
            selectModeWithTile(context),
            dataDescription(context),
            buttonScan(context)
        ],)
      );
    }
  }
