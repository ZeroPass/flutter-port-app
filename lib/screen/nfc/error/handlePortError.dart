import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:logging/logging.dart';
import 'package:port/internal.dart';
import 'package:port/port.dart';
import 'package:dmrtd/extensions.dart';
import 'package:eosio_port_mobile_app/screen/alert.dart';

import 'package:dmrtd/dmrtd.dart';
import '../../../utils/structure.dart';
import '../../flushbar.dart';
import '../passport_scanner.dart';

final _log = Logger("HandlePortError");

class HandlePortError{
  late String _alertTitle;
  late String _alertMsg;

  HandlePortError():
    _alertTitle = '',
    _alertMsg = '';

  Future<bool> handleException({required Object e, required BuildContext context}) async {
    if (e is PassportError)
      return await this._handlePassportError(e: e, context: context);
    else if (e is PassportScannerError)
      return await this._handlePassportScannerError(e: e, context: context);
    else if (e is ArgumentError)
      return await this._handleArgumentError(error: e, context: context);
    else if (e is JRPClientError)
      return await this._handleJRPClientError(error: e, context: context);
    else if (e is HttpException)
      return await this._handleHttpError(error: e, context: context);
    else if (e is SocketException)
      return await this._handleConnectionError(context: context);
    else if (e is HandshakeException)
      return await this._handleHandhakeError(error: e, context: context);
    else if (e is PlatformException)
      return await this._handlePlatformError(error: e, context: context);
    else if (e is PortError)
      return await this._handlePortError(error: e, context: context);
    else
      return await this._handleUnknownError(exception: e,  context: context);
  }

  Future<bool> _handlePlatformError({required PlatformException error, required BuildContext context}) async {
    _log.error("Caught error(PlatformError): [code:${error.code} message: ${error.message??'empty'}]");

    if (error.code == '408')//polling tag timeout
      return Future.value(true);

    return show(context: context);
  }

  Future<bool> _handlePassportError({required PassportError e, required BuildContext context}) async {
    final se = e.toString().toLowerCase();
    if (se.contains('security status not satisfied') || e.code?.sw1 == 0x63) {
      // TODO: 0x63 is standard code for warning, make sure the BAC session has failed when this case is true
      _log.error("BAC session error: ${e.code?.sw1}, Failed to initiate session with passport. Probably wrong input data(>BAC< or >Passport number/Birth date/Expire date<)");
      _alertMsg = 'Failed to initiate session with passport.\nPlease, check input data!';
    }
    if (e.code != null)
      _alertMsg += '\n(error code: ${e.code})';

    _log.error('Failed to scan passport: msg:${e.message}, code:${e.code??-1}');
    return show(context: context);
  }


  Future<bool> _handlePassportScannerError({required PassportScannerError e, required BuildContext context}) async {
    final se = e.toString().toLowerCase();
    _alertTitle = 'An error has occurred while scanning Passport!';

    _log.error('An exception was encountered while trying to scan Passport: $e');
    bool showAlertDialog = true;
    if (se.contains('timeout'))
      _alertMsg = 'Timeout while waiting for Passport tag!';
    else if (se.contains('tag was lost') || se.contains('tag connection lost')) {
      showAlertDialog = false;
      _alertMsg = 'Tag was lost. Please try again!';
    }
    else if (e.code == 200)
      _alertMsg = 'Unsupported passport';
    else if (e.code == 300) {
      showAlertDialog = false;
      _alertMsg = 'Canceled by user';
    }
    else
      _alertMsg = 'An unknown error has occurred while scanning Passport!';

    _log.error("Caught error(PassportScanerError): [Alert title:$_alertTitle message: $_alertMsg]");

    return showAlertDialog ? show(context: context) : Future.value(true);
  }

  Future<bool> _handleConnectionError({required BuildContext context}) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none || !await testConnection()) {
      _alertTitle = 'No Internet connection';
      _alertMsg = 'An internet connection is required!';
    } else {
      _alertTitle = 'Connection error';
      _alertMsg = 'Failed to connect to server.\n'
                  'Check server connection settings.';
    }
    _log.error("Caught error(ConnectionError): [Alert title:$_alertTitle message: $_alertMsg]");
    return show(context: context);
  }

  Future<bool> _handleArgumentError({required ArgumentError error, required BuildContext context}) async {
    _alertTitle = "Connection error";
    _alertMsg = error.message;
    _log.error("Caught error(ArgumentError): [Alert title:$_alertTitle message: $_alertMsg]");
    return show(context: context);
  }

  Future<bool> _handleJRPClientError({required JRPClientError error, required BuildContext context}){
    _alertTitle = "Connection error";
    _alertMsg = "Server not responding. Check your URL address.";
    _log.error("Caught error(JRPClientError): [Alert title:$_alertTitle message: $_alertMsg]");
    return show(context: context);
  }

  Future<bool> _handleHttpError({required HttpException error, required BuildContext context}){
    _alertTitle = "Connection error";
    _alertMsg = error.message;
    _log.error("Caught error(HttpException): [Alert title:$_alertTitle message: $_alertMsg]");
    return show(context: context);
  }

  Future<bool> _handleSocketError({required SocketException error, required BuildContext context}){
    return Future.value(false);
  }

  Future<bool> _handleHandhakeError({required HandshakeException error, required BuildContext context}){
    _alertTitle = "Authentication error";
    _alertMsg = error.toString();
    _log.error("Caught error(HandshakeException): [Alert title:$_alertTitle message: $_alertMsg]");
    return show(context: context);
  }

  Future<bool> _handlePortError({required PortError error, required BuildContext context}){
    _log.error('An unhandled Port exception, closing this screen.\n error=$error');
    _alertTitle = 'Port Error';
    _alertMsg = '';

    switch(error.code){
      case 401: /*PeUnauthorized and PeSigVerifyFailed*/{
        if (error.message == 'Account is not attested')
          _alertMsg = 'Account is not attested anymore!\nPlease re-register new attestation.';
        else if (error.message == 'EF.SOD file not genuine')
          _alertMsg = 'The passport has been already used for attestation!';
        else
          _alertMsg = error.message;
      } break;
      case 403: /*PeForbbidden*/ {
        _alertMsg = error.message;
      } break;
      case 404: /*PeNotFound*/ {
        _alertMsg = error.message;
      } break;
      case 409: /*PeConflict*/ {
        if (error.message == 'Country code mismatch')
          _alertMsg = 'The country of the passport differs from the previous attestation!';
        else if (error.message == 'Matching EF.SOD file already registered')
          _alertMsg = 'The passport has been already used for attestation!';
        else
          _alertMsg = error.message; //for others cases use same error message - also PortError.accountAlreadyRegistered
      } break;
      case 412: /*PeInvalidOrMissingParam*/ {
        _alertMsg = error.message;
      } break;
      case 422: /*PeInvalidOrMissingParam*/{
        _alertMsg = 'Passport verification failed with error "${error.message}"';
      } break;
      case 428: /*PePreconditionRequired*/{
        _alertMsg = error.message;
      }break;
      case 498: /*PeAttestationExpired and PeChallengeExpired*/ {
        _alertMsg = error.message;
      } break;
      default:
        _alertMsg = 'Server returned error:\n\n${error.message}';
    }
    _log.error("Received error(PortError) from server: [Code:${error.code}, Alert message: $alertMsg]");
    return show(context: context);
  }

  Future<bool> _handleUnknownError({required Object exception, required BuildContext context}){
   _alertTitle = 'Error';
   _alertMsg = (exception is Exception)
       ? exception.toString()
       : 'An unknown error has occurred.';
   _log.error("Received error(unknown error): [Alert title:$_alertTitle message: $_alertMsg]");
   _log.error(exception is Exception ? "${exception.toString()}" : "unknown error");
   return show(context: context);
  }

  Future<bool> show({required BuildContext context, bool showCopyButton = true}) async {
     return await showAlert(
         context: context,
         title: Text(_alertTitle,
         style: TextStyle(color: Theme.of(context).errorColor)),
         content: Text(_alertMsg),
         actions: [
           if (showCopyButton)
             PlatformDialogAction(
                 child: PlatformText('Copy',
                     style: TextStyle(
                         color: Theme.of(context).errorColor,
                         fontWeight: FontWeight.bold)),
                 onPressed: () {
                   showFlushbar(context, "Clipboard", "Text from alert was copied to clipboard.", Icons.info, duration: 3);
                   Clipboard.setData(ClipboardData(text: "Title: $_alertTitle, message: $_alertMsg"));
                 }),
           PlatformDialogAction(
           child: PlatformText('Close',
           style: TextStyle(
           color: Theme.of(context).errorColor,
           fontWeight: FontWeight.bold)),
           onPressed: () {
             Navigator.pop(context);
           })
         ]);
  }

  String get alertTitle => _alertTitle;
  String get alertMsg => _alertMsg;
}