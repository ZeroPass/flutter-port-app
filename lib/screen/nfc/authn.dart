import 'dart:async';
import 'dart:io';

//import 'package:connectivity/connectivity.dart';
import 'package:dmrtd/dmrtd.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dmrtd/extensions.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:passid/src/proto/proto_challenge.dart';
import "package:eosio_passid_mobile_app/screen/nfc/passport_scanner.dart";
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:passid/src/authn_data.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
//import 'package:open_settings/open_settings.dart';
import 'package:eosio_passid_mobile_app/screen/customAlert.dart';
import 'package:eosio_passid_mobile_app/utils/structure.dart';
import 'package:passid/passid.dart';
import 'package:logging/logging.dart';


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
                print("---> you should call EfDG1View(dg1)");
                /*return Navigator.push(
                  context,
                  CupertinoPageRoute (
                      builder: (context) => EfDG1View(dg1), fullscreenDialog: true),
                );*/
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


  Future<AuthnData>  _getAuthnData(final ProtoChallenge challenge, String passportID, DateTime birthDate, DateTime validUntil) async {
    //_challenge = challenge;
    scanPassport(challenge, passportID, birthDate, validUntil);
    return _authnData.future;
  }


  Future<void> scanPassport(ProtoChallenge challenge, String passportID, DateTime birthDate, DateTime validUntilDate) async {
    assert(challenge != null);
    try {
      final dbaKeys = DBAKeys(passportID, birthDate, validUntilDate);
      final data = await PassportScanner(
          context: context,
          challenge: challenge,
          action:  AuthnAction.register//_action
      ).scan(dbaKeys);
      Storage storage = Storage();
      await storage.getDBAkeyStorage().setDBAKeys(dbaKeys);
      //await Preferences.setDBAKeys(dbaKeys);  // Save MRZ data
      _authnData.complete(data);
    } catch(e) {
      print("scanPassport error catched");
      print (e);
    } // ignore: empty_catches
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

  void startAction(BuildContext context, AuthnAction action) async {
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
          return await _getAuthnData(challenge, storageStepScan.documentID, storageStepScan.birth, storageStepScan.validUntil).then((data) {
            return data;
          });
        }
        );
      else
        await _client.login((challenge) async {
          StepDataScan storageStepScan = storage.getStorageData(1);
          return await _getAuthnData(challenge, storageStepScan.documentID, storageStepScan.birth, storageStepScan.validUntil).then((data) {
            return data;
          });
        }
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

  @override
  Widget build(BuildContext context) {

      return Container(
          margin: EdgeInsets.all(20),
          child: Row(children: <Widget>[
         FlatButton(
          child: Text('Register'),
          color: Colors.blueAccent,
          textColor: Colors.white,
          onPressed : () => startAction(context, AuthnAction.register)
        ),
            FlatButton(
                child: Text('Login'),
                color: Colors.blueAccent,
                textColor: Colors.white,
                onPressed : () => startAction(context, AuthnAction.login)
            )
        ],)
      );
    }
  }
