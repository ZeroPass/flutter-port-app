//  Created by Crt Vavros, copyright © 2021 ZeroPass. All rights reserved.
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:dmrtd/dmrtd.dart';
import 'package:dmrtd/extensions.dart';
import 'package:eosio_port_mobile_app/screen/nfc/error/handlePortError.dart';
import 'package:eosio_port_mobile_app/utils/structure.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:logging/logging.dart';
import 'package:eosio_port_mobile_app/screen/alert.dart';
import 'package:port/port.dart';


import 'authn/authn.dart';
import 'uie/nfc_scan_dialog.dart';
import 'uie/uiutils.dart';



class PassportData  {
  EfSOD? sod;
  EfDG1? dg1;
  EfDG2? dg2;
  EfDG14? dg14;
  EfDG15? dg15;
  ChallengeSignature? csig;
  PassportData({this.sod, this.dg1, this.dg2, this.dg14, this.dg15, this.csig});
}

//class Register

class PassportScannerError implements Exception {
  final int code;
  final String message;
  PassportScannerError(this.code, this.message);
  @override
  String toString() => message;
}


class PassportScanner {
  final _log = Logger('passport.scanner');
  final _nfc = NfcProvider();
  late NfcScanDialog _scanDialog;
  final PortClient client;
  late HandlePortError handlePortError;

  //final PortAction action;
  //final AuthenticationType? authenticationType;
  final BuildContext context;
  //ProtoChallenge? challenge;

  PassportScanner({required this.context,
                   required this.client,
                   required this.handlePortError
    }) {
        _scanDialog = NfcScanDialog(context, onCancel: () async {
          _log.info('Scanning canceled by user');
          await _cancel();
    });
        //if (this.action == PortAction.assertion && this.authenticationType == null)
        //  throw PassportScannerError('Authentication type is not selected');
  }

  ///From [EfCOM] detect DG files from card
  ///and return what authentication
  ///is going to be executed.
  ///Function creates order of different types
  ///of authentication.
  AuthenticationType getAuthType(EfCOM efCOM){
    final logS = Logger('passport.scanner.selectAuthenticationType');
    AuthenticationType auth = AuthenticationType.None;
    //return auth;
    //most valuable authentication
    if (efCOM.dgTags.contains(EfDG15.TAG)) {
      logS.debug("EfDG15 found. Execute 'PortAuthenticationType.ActiveAuthentication'.");
      auth = AuthenticationType.ActiveAuthentication;
    }
    //less valuable authentication
    else if (efCOM.dgTags.contains(EfDG14.TAG)) {
      logS.debug("EfDG14 found. Execute 'PortAuthenticationType.ChipAuthentication'.");
      auth = AuthenticationType.ChipAuthentication;
    }

    //otherwise do not do any authentication!
    logS.debug('Selected authentication: $auth');
    return auth;
  }

  /// Do active authenticator if there is
  /// Ef.DG15 file. CA should be implemented
  /// in other function.
  Future<PassportData> authenticateAA({required Passport passport, required PassportData passportData, required EfCOM efcom, required ProtoChallenge challenge}) async{
    _log.info("Starting active authentication process");

    //this part is needed because of previous step - reading SOD
    _setAlertMessage(formatProgressMsg('Scanning passport completed', 100));

    final pdata = PassportData();
    _log.debug('Signing challenge ...');

    int progress = 1;
    pdata.csig = ChallengeSignature();
    //do only active authentication, chip authentication will be done in
    //the future; do nothing when there is no authentication
      for (final c in challenge.getChunks(Passport.aaChallengeLen)) {
        _setAlertMessage(formatProgressMsg('Signing challenge ...', progress++ * 20));
        _log.verbose('Signing challenge chunk: ${c.hex()}');
        final sig = await _call(() => passport.activeAuthenticate(c));
        _log.verbose("  Chunk's signature: ${sig!.hex()}");
        pdata.csig!.addSignature(sig);
      }
    _log.debug('Scanning passport completed');
    return pdata;
  }


  /// Get SOD from passport [passport]
  ///
  /// Function returns [PassportData] with SOD
  /// data in structure.
  Future<PassportData> getSOD({required Passport passport, required EfCOM efcom}) async{
    _log.debug("Get SOD from passport");
    final pdata = PassportData();
    _setAlertMessage(formatProgressMsg('Reading data ...', 20));

    if (efcom.dgTags.contains(EfDG15.TAG)) {
      _log.debug("Passport has DG15 file");
      pdata.dg15 = await _call(() => passport.readEfDG15());
      _setAlertMessage(formatProgressMsg('Reading data ...', 40));
      _log.debug('Passport AA public key type: ${pdata.dg15!.aaPublicKey
          .type}');

      if (pdata.dg15!.aaPublicKey.type == AAPublicKeyType.EC) {
        if (!efcom.dgTags.contains(EfDG14.TAG)) {
          //errorMsg = 'Unsupported passport'; //TODO: implement this, check if catch works well
          _log.warning('Strange ... passport should contain file EF.DG14 but is somehow missing?!');
          await _disconnect(errorMessage: formatProgressMsg('Unsupported passport', 100));
          throw PassportScannerError(200, 'Your passport is not supported  yet.');
        }
        pdata.dg14 = await _call(() => passport.readEfDG14());
      }
    }
    else
      _log.debug("Passport has not DG15 file");

    _setAlertMessage(formatProgressMsg('Reading data ...', 50));
    pdata.sod = await _call(() => passport.readEfSOD());
    _setAlertMessage(formatProgressMsg('Scanning passport completed', 79));
    _log.debug('SOD: Scanning passport completed');
    return pdata;
  }


  Future<EfCOM> readStructure({required Passport passport, required DBAKeys dbaKeys}) async {
    _log.info("Read structure");
    _log.debug('Initializing session with passport ...');
    _setAlertMessage('Initiating session ...');
    await _call(() => passport.startSession(dbaKeys));

    _setAlertMessage(formatProgressMsg('Reading data ...', 0));
    final efcom = await _call<EfCOM>(() => passport.readEfCOM());
    _log.debug('EF.COM version: ${efcom!.version}');

    _log.debug('Available data groups: ${formatDgTagSet(efcom.dgTags)}');
    return efcom;
  }

  Future<Map<String, dynamic>> register({required DBAKeys dbaKeys,
                  required UserId uid,
                  required Future<bool> Function(AuthenticationType) waitingOnConfirmation}) async {
    String? errorMsg;
    try {
      _log.debug('Waiting for passport ...');
      await _connect(alertMessage: 'Hold your device near Biometric Passport');
      final passport = Passport(_nfc);

      final efcom = await readStructure(passport: passport, dbaKeys: dbaKeys);
      _log.debug('Reading efCom completed...');

      PassportData passdata = await getSOD(passport: passport, efcom: efcom);
      _log.debug('Reading passData completed ...');

      Map<String, dynamic> srvResult;

      //execute Active Authentication if possible, otherwise just get SOD
      //disclaimer: Chip authentication is not supported yet!
      if (this.getAuthType(efcom) != AuthenticationType.ActiveAuthentication) {
        await _disconnect(alertMessage: formatProgressMsg('Finished', 100));
        _log.debug("Waiting on user confirmation...");
        if (await waitingOnConfirmation(this.getAuthType(efcom))) {
          _log.debug("...user said YES");
          srvResult = await this.client.register(uid,
              passdata.sod!,
              dg15: passdata.dg15,
              dg14: passdata.dg14);
        }
        else {
          _log.debug("...user said NO");
          throw PassportScannerError(300,'Canceled by user');
          }
        }
      else {
         srvResult = await this.client.getAssertion(
            uid, (challenge) async {

              return await authenticateAA(
                  passport: passport,
                  passportData: passdata,
                  efcom: efcom,
                  challenge: challenge).then((PassportData data) async {
                      //no error/exception when passport was scanned
                      await _disconnect(alertMessage: formatProgressMsg('Finished', 100));
                      _log.debug("Waiting on user confirmation...");
                      if (await waitingOnConfirmation(this.getAuthType(efcom))) {
                        _log.debug("...user said YES");
                          _log.debug("Sending 'register' command to the server...");
                          srvResult = await this.client.register(uid,
                              passdata.sod!,
                              dg15: passdata.dg15,
                              dg14: passdata.dg14);
                        _log.debug("Returning signed chunks.");
                        return data.csig!;
                      }
                      else{
                        _log.debug("...user said NO");
                        throw PassportScannerError(300, 'Canceled by user');
                      }
                });
        });
      }
      return srvResult;
    } catch (e) {
      await _disconnect(errorMessage: "Error occurred");
      rethrow; //transfer exception handling to handlePortError
    }
  }


  /// Reads data from passport and signs Port proto [challenge]
  /// with passport's AA private key. Call to this function
  /// displays sheet modal dialog informing the user on scanning progress.
  /// User can also cancel scanning of passport via dialog.
  ///
  /// It returns [AuthnData] according to [action]:
  ///   - register: EfDG15, EfSOD, EfDG14 (Optionally if needed to verify sig)
  ///   - login: EfDG1, EfDG15, EfDG14 (Optionally if needed to verify sig)
  /// In any case the [ChallengeSignature] is returned.
  ///
  /// On error [PassportScannerError] is thrown.
  /// Note: That any error, except for the user cancellation error is
  ///       displayed to the user via sheet dialog.

  /// Cancels current scanning operation
  Future<dynamic>? _cancel() {
    return _operation?.cancel();
  }

  CancelableOperation? _operation;

  /// Invokes [f] via cancelable [_operation].
  /// If operation is canceled a [PassportScannerError] is thrown.
  /// On iOS, the cancellation here should never happen
  /// because it is processed through it's internal NFC framework.
  Future<T?> _call<T>(Future<T> Function() f) async {
    T? result;
    // Check if previous operation was canceled
    // and if not, invoke function f
    if (!(_operation?.isCanceled ?? false)) {
      _operation = CancelableOperation.fromFuture(f());
      result = await _operation!.valueOrCancellation(null);
    }
    if (_operation!.isCanceled) {
      // Note that if current canceled _operation was
      // waiting for NFC job to finish, the NFC job itself was not canceled
      // and it will throw an exception which won't be handled.
      throw PassportScannerError(300, 'Canceled by user');
    }
    return result;
  }

  Future<void> _connect({String? alertMessage}) {
    if (!Platform.isIOS) { // on iOS it's NFC framework handles displaying a NFC scan dialog
      _scanDialog.show(message: alertMessage);
    }
    return _call(() =>_nfc.connect(iosAlertMessage: alertMessage ?? "Hold your iPhone near the biometric Passport"));
  }

  Future<void> _disconnect({String? alertMessage, String? errorMessage}) {
    if (!Platform.isIOS) {
      return _scanDialog.hide(
          message: alertMessage,
          errorMessage: errorMessage,
          delayClosing:
          Duration(milliseconds: (errorMessage != null ? 3500 : 0)));
    }
    return _nfc.disconnect(
        iosAlertMessage: alertMessage, iosErrorMessage: errorMessage);
  }

  void _setAlertMessage(final String msg) {
    if (!Platform.isIOS) {
      _scanDialog.message = msg;
    }
    _nfc.setIosAlertMessage(msg);
  }
}