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
import 'dart:math';

import '../../../port/example/lib/preferences.dart';
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

enum PortAction { register, assertion }
enum AuthenticationType { None, ActiveAuthentication, ChipAuthentication }

class Authn /*extends State<Authn>*/ {
  late PortClient _client;
  late Future<bool> Function(SocketException e) onConnectionError;
  late Future<bool?> Function(AuthenticationType authType) showDataToBeSent;
  late Future<bool?> Function() showBufferScreen;
  late Future<bool> Function(EfDG1 dg1) onDG1FileRequested;

  final _log = Logger('authn.screen');

  Authn({required this.onDG1FileRequested, required this.showDataToBeSent, required this.showBufferScreen, required this.onConnectionError});


  Future<Map<String, dynamic>> _scanPassporRegister({
    required BuildContext context,
    required UserId uid,
    required String passportID,
    required DateTime birthDate,
    required DateTime validUntilDate,
    required Future<bool> Function(AuthenticationType) waitingOnConfirmation}) async {
    final dbaKeys = DBAKeys(passportID, birthDate, validUntilDate);
    final data = await PassportScanner(context: context, client: _client).
                    register(dbaKeys: dbaKeys,
                              uid: uid,
                              waitingOnConfirmation: waitingOnConfirmation);

    Storage storage = Storage();
    await storage.getDBAkeyStorage().setDBAKeys(dbaKeys);
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

  Future<bool?> startAction(BuildContext context,
                            PortAction action,
                            String accountName,
                            NetworkType networkType,
                           {bool fakeAuthnData = false,
                            bool sendDG1 = false,
                            required ScrollController scrollController,
                            required int maxSteps}) async {

    //TODO: accountName is not implemented
    Storage storage = Storage();

    //check if the data is filled correctly
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

      //get address of server
      ServerCloud? serverCloud = storage.outsideCall.isOutsideCall?
        ServerCloud(name: "TemporaryServer", host: storage.outsideCall.getStructV1()!.host.host):
        storage.getServerCloudSelected(networkTypeServer: NetworkTypeServer.MAIN_SERVER);

      if (serverCloud == null)
        throw Exception("ServerCloud (main server) is empty. Without server you cannot check passport trust chain.");

      final httpClient = ServerSecurityContext.getHttpClient(
          timeout: Duration(seconds: serverCloud.timeoutInSeconds))
        ..badCertificateCallback = badCertificateHostCheck;

      _client =  PortClient(serverCloud.host, httpClient: httpClient);
      _client.onConnectionError = this.onConnectionError;

      try {
        await _client.ping(Random().nextInt(0xffffffff));
      } catch (e) {
        _log.error(e);
        throw JRPClientError("Cannot connect to server.");
      }

      Map<String, dynamic> srvResult;

      if (action == PortAction.register) {
        StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
        UserId uid = UserId.fromString(accountName);
        await _hideBusyIndicator();

        await _scanPassporRegister(context: context,
            uid: uid,
            passportID: storageStepScan.getDocumentID(),
            birthDate: storageStepScan.getBirth(),
            validUntilDate: storageStepScan.getValidUntil(),
            waitingOnConfirmation: (AuthenticationType type) async{
              await _hideBusyIndicator();
              var e =  showDataToBeSent(type);

              Future.delayed(const Duration(milliseconds: 999), (){
                scrollController.animateTo(headersHeightTillStep(maxSteps - 1), duration: Duration(milliseconds: 1000), curve: Curves.ease);
              });
              bool? response = await e;
              return response?? false;
            });
      }
      else
        throw Exception("Not known action type");

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
      else if (e is HttpException) {
        alertTitle = "Connection error";
        alertMsg = e.message;
      }
      else if (e is SocketException) {
      } // should be already handled through _handleConnectionError callback
      else if (e is HandshakeException){
        alertTitle = "Authentication error";
        alertMsg = e.toString();
      }
      else if (e is PortError) {
        _log.error('An unhandled Port exception, closing this screen.\n error=$e');
        alertTitle = 'Port Error';
        switch(e.code){
          case -32602: alertMsg= e.message.toLowerCase(); break;
          case 401: alertMsg = 'Authorization failed!'; break;
          case 404: {
            alertMsg = e.message;
            if (alertMsg == 'Account not found') {
              alertMsg = 'Account not registered!';
            }
          } break;
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

  Future<bool?> startNFCAction(BuildContext context, RequestType requestType, String accountName, NetworkType networkType,  ScrollController scrollController, int maxSteps) {
    switch (requestType) {
      case RequestType.ATTESTATION_REQUEST:
        return startAction(context, PortAction.register, accountName, networkType, scrollController: scrollController, maxSteps: maxSteps);
        break;
      case RequestType.PERSONAL_INFORMATION_REQUEST:
        return startAction(context, PortAction.assertion, accountName, networkType, sendDG1: true, scrollController: scrollController, maxSteps: maxSteps);
        break;
      case RequestType.FAKE_PERSONAL_INFORMATION_REQUEST:
        return startAction(context, PortAction.assertion, accountName, networkType,
            fakeAuthnData: true, sendDG1: true, scrollController: scrollController, maxSteps: maxSteps);
        break;
      case RequestType.LOGIN:
        return startAction(context, PortAction.assertion, accountName, networkType, scrollController: scrollController, maxSteps: maxSteps);
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
