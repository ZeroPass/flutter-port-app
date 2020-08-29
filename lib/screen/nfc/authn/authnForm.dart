/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:eosio_passid_mobile_app/utils/size.dart';
import 'package:eosio_passid_mobile_app/screen/nfc/authn/authn.dart';

class AuthnForm extends StatefulWidget {
  AuthnForm() {}

  @override
  _AuthnState createState() => _AuthnFormState();
}

class _AuthnFormState extends State<AuthnForm> {

  @override
  Widget build(BuildContext context) {
    final authnBloc = BlocProvider.of<AuthnBloc>(context);
    return BlocBuilder(
      bloc: authnBloc,
      builder: (BuildContext context, AuthnState state) {
        return Container(
            width: CustomSize.getMaxWidth(context, STEPPER_ICON_PADDING),
            child: Form(
              autovalidate: true,
              child:Authn()
            )
        );
      },
    );
  }
}
*/

import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';

import 'package:dmrtd/dmrtd.dart';
import 'package:dmrtd/extensions.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:eosio_passid_mobile_app/screen/alert.dart';
import 'package:eosio_passid_mobile_app/screen/customButton.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:eosio_passid_mobile_app/screen/nfc/authn/authn.dart';

import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/utils/structure.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import 'package:eosio_passid_mobile_app/screen/requestType.dart';

import 'package:logging/logging.dart';
import 'package:passid/passid.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eosio_passid_mobile_app/screen/flushbar.dart';

import '../efdg1_dialog.dart';
import '../passport_scanner.dart';
import '../uie/uiutils.dart';


class ServerSecurityContext {
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
    if (timeout != null) {
      c.connectionTimeout = timeout;
    }
    return c;
  }
}

enum AuthnAction { register, login }

class AuthnForm extends StatefulWidget {

  AuthnForm({Key key});

  _AuthnForm createState() => _AuthnForm();
}

class _AuthnForm extends State<AuthnForm> {
  PassIdClient _client;
  final _log = Logger('authn.screen');
  final String _fakeName = "Larimer Daniel";

  Future<bool> _handleConnectionError(final SocketException e) async {
    String title;
    String msg;
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none ||
        !await testConnection()) {
      title = 'No Internet connection';
      msg = 'An internet connection is required!';
    } else {
      //settingsAction = () => _settingsButton.onPressed();
      title = 'Connection error';
      msg = 'Failed to connect to server.\n'
          'Check server connection settings.';
    }
    await _hideBusyIndicator();
    showFlushbar(title, msg);
    return Future<bool>.value(false);
  }

  Future<bool> showDG1(final EfDG1 dg1) async {
    return _showDG1Dialog(dg1, msg: 'Server requested additional data');
  }

  Future<bool> _handleDG1Request(final EfDG1 dg1) async {
    return _showDG1Dialog(dg1, msg: 'Server requested additional data');
  }

  Future<AuthnData> _getAuthnData(
      final ProtoChallenge challenge,
      AuthnAction action,
      String passportID,
      DateTime birthDate,
      DateTime validUntil) async {
    return _scanPassport(challenge, action, passportID, birthDate, validUntil);
  }

  Future<AuthnData> _scanPassport(ProtoChallenge challenge, AuthnAction action,
      String passportID, DateTime birthDate, DateTime validUntilDate) async {
    assert(challenge != null);
    final dbaKeys = DBAKeys(passportID, birthDate, validUntilDate);
    final data = await PassportScanner(
        context: context, challenge: challenge, action: action)
        .scan(dbaKeys);

    Storage storage = Storage();
    await storage.getDBAkeyStorage().setDBAKeys(dbaKeys);
    //await Preferences.setDBAKeys(dbaKeys);  // Save MRZ data
    return data;
  }

  String checkValuesInStorage() {
    String missingValuesText = '';
    Storage storage = Storage();
    StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0);
    if (storageStepEnterAccount.isUnlocked == false &&
        storage.selectedNode.name != "ZeroPass Server")
      missingValuesText +=
      "- Account name is not valid.\n (Step 'Account')\n\n";

    StepDataScan storageStepScan = storage.getStorageData(1);
    if (storageStepScan.documentID == null)
      missingValuesText +=
      "- Passport Number is not valid.\n (Step 'Passport Info')\n\n";
    if (storageStepScan.birth == null)
      missingValuesText +=
      "- Date of Birth is not valid.\n (Step 'Passport Info')\n\n";
    if (storageStepScan.validUntil == null)
      missingValuesText +=
      "- Date of Expiry is not valid.\n (Step 'Passport Info')";
    return missingValuesText;
  }

  Future<bool> startAction(BuildContext context, AuthnAction action,
      {bool fakeAuthnData = false, bool sendDG1 = false}) async {
    Storage storage = Storage();
    String checkedValues = checkValuesInStorage();
    if (checkedValues.isNotEmpty) {
      await showAlert(
          context: context,
          title: Text('Error'),
          content: Text("Invalid or missing data!\n\n" + checkedValues),
          actions: [
            PlatformDialogAction(
                child: PlatformText('Close',
                    style: TextStyle(
                        color: Theme.of(context).errorColor,
                        fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.pop(context))
          ]);
      //return Future<bool>.value(false);
    }
    try {
      _showBusyIndicator();
      final httpClient = ServerSecurityContext.getHttpClient(
          timeout: Duration(seconds: storage.storageServer.timeoutInSeconds))
        ..badCertificateCallback = badCertificateHostCheck;

      _client = PassIdClient(Uri.parse(storage.storageServer.toString()),
          httpClient: httpClient);
      _client.onConnectionError = _handleConnectionError;
      _client.onDG1FileRequested = _handleDG1Request;

      if (action == AuthnAction.register)
        await _client.register((challenge) async {
          StepDataScan storageStepScan = storage.getStorageData(1);
          await _hideBusyIndicator();
          return _getAuthnData(
              challenge,
              AuthnAction.register,
              storageStepScan.documentID,
              storageStepScan.birth,
              storageStepScan.validUntil)
              .then((data) async {
            await _showBusyIndicator();
            return data;
          });
        });
      else
        await _client.login((challenge) async {
          StepDataScan storageStepScan = storage.getStorageData(1);
          await _hideBusyIndicator();
          return _getAuthnData(
              challenge,
              AuthnAction.login,
              storageStepScan.documentID,
              storageStepScan.birth,
              storageStepScan.validUntil)
              .then((data) async {
            if (fakeAuthnData) {
              data = _fakeData(data);
            }
            if (sendDG1) {
              if (!await _showDG1Dialog(data.dg1)) {
                // User said no.
                // Throw an exception just to get us out of this scope.
                // An exception should not show any error dialog to user.
                throw PassportScannerError('Get me out');
              }
            }

            await _showBusyIndicator();
            return data;
          });
        }, sendEfDG1: sendDG1);

      final srvMsgGreeting = await _client.requestGreeting();
      await _hideBusyIndicator();
      await showAlert(
          context: context,
          title: Text('Attestation Succeeded'),
          content: Text(_formatAttestationSuccess(srvMsgGreeting)),
          actions: [
            PlatformDialogAction(
                child: PlatformText('Close',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.pop(context))
          ]);

      //storage.getDBAkeyStorage().init();
    } catch (e) {
      String alertTitle;
      String alertMsg;
      if (e is PassportScannerError) {
      } // should be already handled in PassportScanner
      else if (e is SocketException) {
      } // should be already handled through _handleConnectionError callback
      else if (e is PassIdError) {
        if (!e.isDG1Required()) {
          // DG1 required error should be handled through _handleDG1Request callback
          _log.error(
              'An unhandled passId exception, closing this screen.\n error=$e');
          alertTitle = 'PassID Error';
          final msg = e.message.toLowerCase();
          switch (e.code) {
            case 401:
              alertMsg = 'Attestation failed!';
              break;
          //case 404: // TODO: parse message and translate it to system language
            case 406:
              {
                alertMsg = 'Passport verification failed!';
                if (msg.contains('invalid dg1 file')) {
                  alertMsg = 'Server refused to accept sent personal data!';
                } else if (msg.contains('invalid dg15 file')) {
                  alertMsg = "Server refused to accept passport's public key!";
                }
              }
              break;
            case 409:
              alertMsg = 'Account already exists!';
              break;
            case 412:
              alertTitle = 'Attestation failed';
              alertMsg = 'Passport trust chain verification failed!';
              if (msg.contains('invalid')) {
                alertMsg = 'Invalid passport data';
                if (fakeAuthnData) {
                  alertMsg = "Could not attest you as $_fakeName";
                }
              }
              break;
            case 498:
              {
                if (msg.contains('account has expired')) {
                  alertMsg = 'Account has expired, please register again!';
                  break;
                }
              }
              continue dflt;
            dflt:
            default:
              alertMsg = 'Server returned error:\n\n${e.message}';
          }
        }
      } else {
        _log.error(
            'An unhandled exception was encountered, closing this screen.\n error=$e');
        alertTitle = 'Error';
        alertMsg = (e is Exception)
            ? e.toString().split('Exception: ').first
            : 'An unknown error has occurred.';
      }

      // Show alert dialog
      await _hideBusyIndicator();
      if (alertMsg != null && alertTitle != null) {
        await showAlert(
            context: context,
            title: Text(alertTitle,
                style: TextStyle(color: Theme.of(context).errorColor)),
            content: Text(alertMsg),
            actions: [
              PlatformDialogAction(
                  child: PlatformText('Close',
                      style: TextStyle(
                          color: Theme.of(context).errorColor,
                          fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.pop(context))
            ]);
      }
    }
  }

  AuthnData _fakeData(AuthnData data) {
    // Fake the name of passport owner
    final rawDG1 = data.dg1.toBytes();
    final name = _fakeName.replaceAll(' ', '<<');
    // Works for TD3 (passport MRZ) only.
    // On other formats (TD1, TD2) will write to the wrong location.
    for (int i = 0; i < 39; i++) {
      int b = '<'.codeUnitAt(0);
      if (i < name.length) {
        b = name[i].codeUnitAt(0);
      }
      rawDG1[i + 10] = b; // The name field starts at position 10 on TD3
    }
    final dg1 = EfDG1.fromBytes(rawDG1);
    return AuthnData(dg15: data.dg15, csig: data.csig, dg1: dg1);
  }

  String _formatAttestationSuccess(String greeting) {
    var names = greeting.replaceAll('Hi, ', '');
    names = names.replaceAll('!', '');
    return "You're attested as $names";
  }

  Widget buttonScan(var context) {
    return Row(
      //mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 0),
            child: PlatformButton(
              child: Text('Attest and Send'),
              color: Color(0xFFa58157),
              //iosFilled: (_) => CupertinoFilledButtonData(),
              onPressed: () {
                //remove system bottom navigation bar
                Storage storage = Storage();
                StepDataAttestation stepDataAttestation = storage.getStorageData(2);

                removeNavigationBar();
                switch(stepDataAttestation.requestType) {
                  case RequestType.ATTESTATION_REQUEST:
                    startAction(context, AuthnAction.register);
                    break;
                  case RequestType.PERSONAL_INFORMATION_REQUEST:
                    startAction(context, AuthnAction.login, sendDG1: true);
                    break;
                  case RequestType.FAKE_PERSONAL_INFORMATION_REQUEST:
                    startAction(context, AuthnAction.login,
                        fakeAuthnData: true, sendDG1: true);
                    break;
                  case RequestType.LOGIN:
                    startAction(context, AuthnAction.login);
                    break;

                  default:
                    throw new Exception("Request type is not known.");
                }
                changeNavigationBarColor();
              },
            ))
      ],
    );
  }

  Future<bool> startNFCAction(BuildContext context)
  {
    Storage storage = Storage();
    StepDataAttestation stepDataAttestation = storage.getStorageData(2);

    switch(stepDataAttestation.requestType) {
      case RequestType.ATTESTATION_REQUEST:
        return startAction(context, AuthnAction.register);
        break;
      case RequestType.PERSONAL_INFORMATION_REQUEST:
        return startAction(context, AuthnAction.login, sendDG1: true);
        break;
      case RequestType.FAKE_PERSONAL_INFORMATION_REQUEST:
        return startAction(context, AuthnAction.login,
            fakeAuthnData: true, sendDG1: true);
        break;
      case RequestType.LOGIN:
        return startAction(context, AuthnAction.login);
        break;

      default:
        throw new Exception("Request type is not known.");
    }
    changeNavigationBarColor();
  }

  bool _isBusyIndicatorVisible = false;
  final GlobalKey<State> _keyBusyIndicator =
  GlobalKey<State>(debugLabel: 'key_authn_busy_indicator');
  Future<void> _showBusyIndicator({String msg = 'Please Wait ....'}) async {
    await _hideBusyIndicator();
    await showBusyDialog(context, _keyBusyIndicator, msg: msg);
    _isBusyIndicatorVisible = true;
  }

  Future<void> _hideBusyIndicator(
      {Duration syncWait = const Duration(milliseconds: 200)}) async {
    if (_keyBusyIndicator.currentContext != null) {
      await hideBusyDialog(_keyBusyIndicator, syncWait: syncWait);
      _isBusyIndicatorVisible = false;
    } else if (_isBusyIndicatorVisible) {
      await Future.delayed(const Duration(milliseconds: 200), () async {
        await _hideBusyIndicator();
      });
    }
  }

  Future<bool> _showDG1Dialog(final EfDG1 dg1, {String msg = null}) async {
    _log.debug('Showing EfDG1 dialog');

    final authnBloc = BlocProvider.of<AuthnBloc>(context);
    Storage storage = new Storage();
    StepDataAttestation stepDataAttestation = storage.getStorageData(2);

    StepperBloc stepperBloc = BlocProvider.of<StepperBloc>(context);
    //unlock review tab in stepper
    stepperBloc.isReviewLocked = false;
    //change header in stepper
    stepperBloc.liveModifyHeader(3, context, dataInStep: true);

    Completer<bool> send = new Completer<bool>();
    authnBloc.add(WithDataEvent(dg1: dg1, msg: msg, outsideCall: stepDataAttestation.isOutsideCall, sendData: (bool isDataSent)
    {
      send.complete(isDataSent);
    }));
    return send.future;
  }

  @override
  Widget build(BuildContext context) {
    final authnBloc = BlocProvider.of<AuthnBloc>(context);

    StepperBloc stepperBloc = BlocProvider.of<StepperBloc>(context);

    //start the action only when 4th step is opened
    if (stepperBloc.state.step == stepperBloc.state.maxSteps-1)
      startNFCAction(context).then((bool value) {
        stepperBloc.add(StepBackToPrevious());
    });

    return BlocBuilder(
        bloc: authnBloc,
        builder: (BuildContext context, AuthnState state) {
          //if (state is WithDataEvent)

    return Container(
        child: Column(
          children: <Widget>[
            if (state is WithDataState)
              Align(
                  alignment: Alignment.centerLeft,
                  child:Text('Review what data will be send to ' + (state.outsideCall.isOutsideCall ? state.outsideCall.requestedBy : 'the blockchain.'),
                  style: TextStyle(color: AndroidThemeST().getValues().themeValues["STEPPER"]
                    ["STEP_TAP"]["COLOR_TEXT"]),
              )),
            if (state is WithDataState)
              EfDG1Dialog(
                  context: context,
                  dg1: state.dg1,
                  message: state.msg,
                  actions:  [
                    /*PlatformButton(
                      child: Text('Cancel'),
                      color: Color(0xFFa58157),
                      //iosFilled: (_) => CupertinoFilledButtonData(),
                      onPressed: () {
                        authnBloc.add(WithoutDataEvent());
                        state.sendData(false);
                      },
                    ),*/
                    PlatformButton(
                      child: Text('Send'),
                      color: Color(0xFFa58157),
                      //iosFilled: (_) => CupertinoFilledButtonData(),
                      onPressed: () {
                        authnBloc.add(WithoutDataEvent());
                        stepperBloc.isReviewLocked = true;
                        state.sendData(true);
                      },
                    )
              ])

          ],
        ));
  });
}
}