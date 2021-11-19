//  Created by Crt Vavros, copyright © 2021 ZeroPass. All rights reserved.
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:dmrtd/dmrtd.dart';
import 'package:dmrtd/extensions.dart';
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


class PassportScannerError implements Exception {
  final String message;
  PassportScannerError(this.message);
  @override
  String toString() => message;
}

class PassportScanner {
  final _log = Logger('passport.scanner');
  final _nfc = NfcProvider();
  late NfcScanDialog _scanDialog;

  PortAction action;
  final BuildContext context;
  ProtoChallenge? challenge;

  PassportScanner(
      {required this.context, this.challenge, required this.action}) {
    _scanDialog = NfcScanDialog(context, onCancel: () async {
      _log.info('Scanning canceled by user');
      await _cancel();
    });
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
  Future<PassportData> scan(final DBAKeys dbaKeys) async {
    if (challenge == null) {
      throw PassportScannerError('challenge is null');
    }

    String? errorMsg;
    try {
      _log.debug('Waiting for passport ...');
      await _connect(alertMessage: 'Hold your device near Biometric Passport');
      final passport = Passport(_nfc);

      _log.debug('Initializing session with passport ...');
      _setAlertMessage('Initiating session ...');
      await _call(() => passport.startSession(dbaKeys));

      _setAlertMessage(formatProgressMsg('Reading data ...', 0));
      final efcom = await _call<EfCOM>(() => passport.readEfCOM());
      _log.debug('EF.COM version: ${efcom!.version}');

      _log.debug('Available data groups: ${formatDgTagSet(efcom.dgTags)}');
      if ((action == PortAction.register || action == PortAction.login)
          && !efcom.dgTags.containsAll([EfDG1.TAG, EfDG15.TAG])) {
        _log.info('Unsupported passport - '
            "missing file ${efcom.dgTags.contains(EfDG1.TAG) ? "Ef.DG15" : "EF.DG1"}");
        errorMsg = 'Unsupported passport';
        await _showUnsupportedMrtdAlert();
        throw PassportScannerError('Unsupported passport');
      }

      final pdata = PassportData();
      if (action == PortAction.register) {
        // _setAlertMessage(formatProgressMsg('Reading data ...', 20));
        // if (action == PortAction.login) {
        //   pdata.dg1 = await _call(() => passport.readEfDG1());
        // }
        _setAlertMessage(formatProgressMsg('Reading data ...', 20));
        pdata.dg15 = await _call(() => passport.readEfDG15());
        _log.debug('Passport AA public key type: ${pdata.dg15!.aaPublicKey.type}');
        if (pdata.dg15!.aaPublicKey.type == AAPublicKeyType.EC) {
          if (!efcom.dgTags.contains(EfDG14.TAG)) {
            errorMsg = 'Unsupported passport';
            _log.warning(
                'Strange ... passport should contain file EF.DG14 but is somehow missing?!');
            await _showUnsupportedMrtdAlert(); // TODO: show more descriptive alert dialog
            throw PassportScannerError('Unsupported passport');
          }
          pdata.dg14 = await _call(() => passport.readEfDG14());
        }

        _setAlertMessage(formatProgressMsg('Reading data ...', 60));
        pdata.sod = await _call(() => passport.readEfSOD());
      }

      _log.debug('Signing challenge ...');
      _setAlertMessage(formatProgressMsg('Signing challenge ...', 80));
      pdata.csig = ChallengeSignature();
      for (final c in challenge!.getChunks(Passport.aaChallengeLen)) {
        _log.verbose('Signing challenge chunk: ${c.hex()}');
        final sig = await _call(() => passport.activeAuthenticate(c));
        _log.verbose("  Chunk's signature: ${sig!.hex()}");
        pdata.csig!.addSignature(sig);
      }

      _log.debug('Scanning passport completed');
      return pdata;
    } on PassportScannerError {
      rethrow;
    } catch (e) {
      final se = e.toString().toLowerCase();
      errorMsg = 'An error has occurred while scanning Passport!';
      if (e is PassportError) {
        if (se.contains('security status not satisfied')) {
          errorMsg =
          'Failed to initiate session with passport.\nPlease, check input data!';
        }
        if (e.code != null) {
          errorMsg += '\n(error code: ${e.code})';
        }
        _log.error('Failed to scan passport: ${e.message}');
      } else {
        errorMsg = 'An unknown error has occurred while scanning Passport!';
        _log.error(
            'An exception was encountered while trying to scan Passport: $e');
      }

      if (se.contains('timeout')) {
        errorMsg = 'Timeout while waiting for Passport tag!';
      } else if (se.contains('tag was lost') ||
          se.contains('tag connection lost')) {
        errorMsg = 'Tag was lost. Please try again!';
      } else if (se.contains('invalidated by user')) {
        errorMsg = '';
        throw PassportScannerError('Canceled by user');
      }
      throw PassportScannerError(errorMsg);
    } finally {
      if (errorMsg != null) {
        await _disconnect(errorMessage: errorMsg);
      } else {
        await _disconnect(alertMessage: formatProgressMsg('Finished', 100));
      }
    }
  }

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
      throw PassportScannerError('Canceled by user');
    }
    return result;
  }

  Future<void> _showUnsupportedMrtdAlert() async {
    await showAlert(context: context, title: Text('Unsupported Passport'),
        content: Text('This passport is not supported!'),
        actions: [
          PlatformDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text(
            'CLOSE',
            style: TextStyle(fontWeight: FontWeight.bold),
            ))
        ]);
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
          Duration(milliseconds: (errorMessage != null ? 3500 : 2500)));
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