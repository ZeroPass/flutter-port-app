import 'dart:async';
import 'dart:io';

import 'package:dmrtd/dmrtd.dart';
import 'package:dmrtd/extensions.dart';
import 'package:eosio_port_mobile_app/constants/constants.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_port_mobile_app/screen/alert.dart';

import 'package:eosio_port_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepScan/stepScan.dart';

import 'package:eosio_port_mobile_app/utils/storage.dart';
import 'package:eosio_port_mobile_app/utils/structure.dart';
import 'package:eosio_port_mobile_app/screen/theme.dart';
import 'package:eosio_port_mobile_app/screen/requestType.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/customStepper.dart';

import 'package:logging/logging.dart';
import 'package:port/internal.dart';
import 'package:port/port.dart';

import '../efdg1_dialog.dart';
import '../passport_scanner.dart';
import '../uie/uiutils.dart';

class ServerSecurityContext {
  static SecurityContext _ctx = SecurityContext();

  /// 'Globally' init ctx using server certificate (.cer) bytes.
  /// [servCertBytes] should be single certificate because sha1
  /// is calculated over these bytes and checked against sha1 of
  /// certificate in _certificateCheck.
  static init(List<int> servCertBytes) {
    _ctx.setTrustedCertificatesBytes(servCertBytes);
  }

  static HttpClient getHttpClient({Duration? timeout}) {
    final c = HttpClient(context: _ctx);
    if (timeout != null) {
      c.connectionTimeout = timeout;
    }
    return c;
  }
}

enum AuthnAction { register, login }

class Authn /*extends State<Authn>*/ {
  late PortClient _client;
  late Future<bool> Function(SocketException e) onConnectionError;
  late Future<bool?> Function() showDataToBeSent;
  late Future<bool?> Function() showBufferScreen;
  late Future<bool> Function(EfDG1 dg1) onDG1FileRequested;

  final _log = Logger('authn.screen');
  final String _fakeName = "Trump Melania";

  Authn({required this.onDG1FileRequested, required this.showDataToBeSent, required this.showBufferScreen, required this.onConnectionError});

  Future<AuthnData> _getAuthnData(
      BuildContext context,
      final ProtoChallenge challenge,
      AuthnAction action,
      String passportID,
      DateTime birthDate,
      DateTime validUntil) async {
    return _scanPassport(
        context, challenge, action, passportID, birthDate, validUntil);
  }

  Future<AuthnData> _scanPassport(
      BuildContext context,
      ProtoChallenge challenge,
      AuthnAction action,
      String passportID,
      DateTime birthDate,
      DateTime validUntilDate) async {
    assert(challenge != null);
    final dbaKeys = DBAKeys(passportID, birthDate, validUntilDate);
    final data = await PassportScanner(
        context: context, challenge: challenge, action: action).scan(dbaKeys);

    Storage storage = Storage();
    await storage.getDBAkeyStorage().setDBAKeys(dbaKeys);
    //await Preferences.setDBAKeys(dbaKeys);  // Save MRZ data
    return data;
  }

  String checkValuesInStorage() {
    String missingValuesText = '';
    Storage storage = Storage();
    StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0) as StepDataEnterAccount;
    if (storageStepEnterAccount.isUnlocked == false
        /*&& storage.selectedNode.name != "ZeroPass Server"*/)
      missingValuesText +=
          "- Account name is not valid.\n (Step 'Account')\n\n";

    StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
    if (storageStepScan.isValidDocumentID() == false)
      missingValuesText +=
          "- Passport Number is not valid.\n (Step 'Passport Info')\n\n";
    if (storageStepScan.isValidBirth() == false)
      missingValuesText +=
          "- Date of Birth is not valid.\n (Step 'Passport Info')\n\n";
    if (storageStepScan.isValidValidUntil() == false)
      missingValuesText +=
          "- Date of Expiry is not valid.\n (Step 'Passport Info')";
    return missingValuesText;
  }

  Future<bool?> startAction(BuildContext context, AuthnAction action,
      String accountName, NetworkType networkType,
      {bool fakeAuthnData = false, bool sendDG1 = false, required ScrollController scrollController, required int maxSteps}) async {
    //TODO: accountName is not implemented
    Storage storage = Storage();
    String checkedValues = checkValuesInStorage();
    if (checkedValues.isNotEmpty) {
      return showAlert<bool?>(
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
    }
    //outside call verifications
    if (storage.outsideCall.isOutsideCall){
      //TODO: check if there is any anomalies


    }

    try {
      _showBusyIndicator(context);
      ServerCloud? serverCloud = storage.outsideCall.isOutsideCall?
        ServerCloud(name: "TemporaryServer", host: storage.outsideCall.getStructV1()!.host.host):
        storage.getServerCloudSelected(networkTypeServer: NetworkTypeServer.MAIN_SERVER);

      if (serverCloud == null)
        throw Exception("ServerCloud (main server) is empty. Without server you cannot check passport trust chain.");

      StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
      if (storageStepScan.isValidDocumentID() == false ||
          storageStepScan.isValidBirth() == false ||
          storageStepScan.isValidValidUntil() == false)
        throw Exception("authn.startAction: DocumentID, Birth or ValidUntil variable is null.");


      final httpClient = ServerSecurityContext.getHttpClient(
          timeout: Duration(seconds: serverCloud.timeoutInSeconds))
        ..badCertificateCallback = badCertificateHostCheck;

      _client =  PortClient(serverCloud.host, httpClient: httpClient);
      _client.onConnectionError = this.onConnectionError;
      _client.onDG1FileRequested = this.onDG1FileRequested;

      if (action == AuthnAction.register) {
        await _client.register((challenge) async {

          await _hideBusyIndicator();
          return _getAuthnData(
              context,
              challenge,
              AuthnAction.register,
              storageStepScan.getDocumentID(),
              storageStepScan.getBirth(),
              storageStepScan.getValidUntil())
              .then((data) async {
            var e =  showDataToBeSent();
            Future.delayed(const Duration(milliseconds: 999), (){
              scrollController.animateTo(headersHeightTillStep(maxSteps - 1), duration: Duration(milliseconds: 1000), curve: Curves.ease);
            });
            bool? response = await e;
            if (response == null || !response) {
              // User said no.
              throw PassportScannerError('Get me out');
            }
            await this.showBufferScreen();
            return data;
          });
        });
        //await e;
      }
      else
        await _client.login((challenge) async {
          StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
          await _hideBusyIndicator();
          return _getAuthnData(
                  context,
                  challenge,
                  AuthnAction.login,
                  storageStepScan.getDocumentID(),
                  storageStepScan.getBirth(),
                  storageStepScan.getValidUntil())
                  .then((data) async {
            if (fakeAuthnData) {
              data = _fakeData(data);
            }
            if (sendDG1) {
              if (data != null && data.dg1 != null ) {
                var responseDG1 = await this.onDG1FileRequested(data.dg1!);
                Future.delayed(const Duration(milliseconds: 999), () {
                  scrollController.animateTo(
                      headersHeightTillStep(maxSteps - 1),
                      duration: Duration(milliseconds: 1000),
                      curve: Curves.ease);
                });

                bool? response = responseDG1;
                if (response == null || !response) {
                  // User said no.
                  // Throw an exception just to get us out of this scope.
                  // An exception should not show any error dialog to user.
                  throw PassportScannerError('Get me out');
                }
              }
              else
                throw Exception("No data or data.dg1.");
            }
            else {
              var e =  showDataToBeSent();
              Future.delayed(const Duration(milliseconds: 999), (){
                scrollController.animateTo(headersHeightTillStep(maxSteps - 1), duration: Duration(milliseconds: 1000), curve: Curves.ease);
              });
              bool? response = await e;
              if (response == null || !response) {
                // User said no.
                throw PassportScannerError('Get me out');
              }
            }
            await this.showBufferScreen();
            return data;
          });
        }, sendEfDG1: sendDG1);

      await _hideBusyIndicator();
      return true;

    } catch (e) {
      String? alertTitle;
      String? alertMsg;
      if (e is PassportScannerError) {
      } // should be already handled in PassportScanner
      else if (e is ArgumentError) {
        alertTitle = "Connection error";
        alertMsg = e.message;
      }
      else if (e is JRPClientError) {
        alertTitle = "Connection error";
        alertMsg = "Server not responding. Check your URL address.";
      }
      else if (e is SocketException) {
      } // should be already handled through _handleConnectionError callback
      else if (e is HandshakeException){
        alertTitle = "Authentication error";
        alertMsg = e.message;
      }
      else if (e is PortError) {
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
        await _hideBusyIndicator();
        return false;
      }
      return false;
    }
  }

  AuthnData _fakeData(AuthnData data) {
    // Fake the name of passport owner
    if (data.dg1 == null)
      throw Exception("Function _fakeData; no dg1");
    final rawDG1 = data.dg1!.toBytes();
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

  Future<bool?> startNFCAction(BuildContext context, RequestType requestType, String accountName, NetworkType networkType,  ScrollController scrollController, int maxSteps) {
    switch (requestType) {
      case RequestType.ATTESTATION_REQUEST:
        return startAction(context, AuthnAction.register, accountName, networkType, scrollController: scrollController, maxSteps: maxSteps);
        break;
      case RequestType.PERSONAL_INFORMATION_REQUEST:
        return startAction(context, AuthnAction.login, accountName, networkType, sendDG1: true, scrollController: scrollController, maxSteps: maxSteps);
        break;
      case RequestType.FAKE_PERSONAL_INFORMATION_REQUEST:
        return startAction(context, AuthnAction.login, accountName, networkType,
            fakeAuthnData: true, sendDG1: true, scrollController: scrollController, maxSteps: maxSteps);
        break;
      case RequestType.LOGIN:
        return startAction(context, AuthnAction.login, accountName, networkType, scrollController: scrollController, maxSteps: maxSteps);
        break;

      default:
        throw new Exception("Request type is not known.");
    }
  }

  bool _isBusyIndicatorVisible = false;
  GlobalKey<State> _keyBusyIndicator =
      GlobalKey<State>(debugLabel: 'key_authn_busy_indicator');

  Future<void> _showBusyIndicator(BuildContext context,
      {String msg = 'Please Wait ....'}) async {
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

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        /*EfDG1Dialog(
          context: context,
        )*/
        Text("Unimplemented")
      ],
    ));
  }
}
