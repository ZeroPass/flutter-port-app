//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'package:async/async.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'uiutils.dart';

/// Class displays BottomSheet dialog which
/// shows to the user NFC scanning state via [message].
class NfcScanDialog {
  final BuildContext context;

  // Get or set currently displayed message
  String get message => _msg;
  set message(String message) => _setMessage(message);

  /// Constructs new [NfcScanDialog] using [context] and optionally
  /// [onCancel] callback which is called when user presses cancel button.
  /// If callback [onCancel] is not provided or null the cancel button will be hidden.
  NfcScanDialog(this.context, {Function() onCancel}) : _onCancelCB = onCancel {
    _showCancelButton = _onCancelCB != null;
  }

  /// Shows bottom dialog with optionally [message] string.
  Future<T> show<T>({String message}) {
    return _showBottomSheet<T>(message).then((value) async {
      if (_closingOperation != null) {
        await _closingOperation.cancel();
        _closingOperation = null;
      }
      else if (_sheetSetter != null) {
        // dialog was closed without user clicking cancel button
        _sheetSetter = null;
        await _onCancel();
      }
      return value;
    });
  }

  /// Hides dialog.
  /// If [message] or [errorMessage] is provided closing dialog will be delayed for [delayClosing] period.
  /// If both [message] and [errorMessage] are set the [errorMessage] will be used.
  Future<void> hide(
      {String message,
      String errorMessage,
      Duration delayClosing = const Duration(milliseconds: 2500)}) {
    return _closeBottomSheet(
        message: message,
        errorMessage: errorMessage,
        delayClosing: delayClosing);
  }

  String _msg;
  String _iconAnimation = _IconAnimations.animWaiting;
  StateSetter _sheetSetter;

  CancelableOperation _closingOperation;
  final Function _onCancelCB;
  bool _showCancelButton;

  void _setMessage(final String msg) {
    if (_sheetSetter != null) {
      _sheetSetter(() {
        _iconAnimation = _IconAnimations.animScanning;
        _msg = msg ?? '';
      });
    } else {
      _msg = msg ?? '';
    }
  }

  Future<T> _showBottomSheet<T>(String msg) {
    if (_sheetSetter != null) {
      return null;
    }

    _showCancelButton = _onCancelCB != null;
    _iconAnimation = _IconAnimations.animWaiting;
    _msg = msg ?? '';
    return showModalBottomSheet(
        context: context,
        //backgroundColor: Colors.white,
        isDismissible: false,
        useRootNavigator: true,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            _sheetSetter = setState;
            return WillPopScope(
                onWillPop: () async => false,
                child: Container(
                    height: MediaQuery.of(context).size.width,
                    child: Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text('Ready to Scan',
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.grey)),
                              const SizedBox(height: 30),
                              Container(
                                  width: 100,
                                  height: 100,
                                  child: FlareActor.asset(
                                    _IconAnimations.file,
                                    alignment: Alignment.center,
                                    fit: BoxFit.cover,
                                    animation: _iconAnimation,
                                  )),
                              const SizedBox(height: 15),
                              ConstrainedBox(
                                  constraints: BoxConstraints(minHeight: 60),
                                  child: Row(children: <Widget>[
                                    Expanded(
                                        child: Text(_msg,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 16)))
                                  ])),
                              const SizedBox(height: 10),
                              makeButton(
                                visible: _showCancelButton,
                                context: context,
                                text: 'CANCEL',
                                margin: null,
                                onPressed: _onCancel
                              )
                            ],
                          ),
                        ))));
          });
        });
  }

  Future<void> _closeBottomSheet(
      {String message, String errorMessage, Duration delayClosing}) {
    if (_sheetSetter != null) {
      if(_closingOperation != null) {
        _closingOperation.cancel();
        _closingOperation = null;
      }

      if ((message != null || errorMessage != null)) {
        _sheetSetter(() {
          _showCancelButton = false;
          if (errorMessage != null) {
            _msg = errorMessage;
            _iconAnimation = _IconAnimations.animError;
          } else if (message != null) {
            _msg = message;
            _iconAnimation = _IconAnimations.animSuccess;
          }
        });

        if (delayClosing != null) {
          // Delay closing dialog to display message
          _closingOperation = CancelableOperation.fromFuture(
              Future.delayed(delayClosing)
          ).then((value) {
            if (_sheetSetter != null) {
              _sheetSetter = null;
              Navigator.pop(context);
            }
          });
          return _closingOperation.valueOrCancellation();
        }
      }
      _sheetSetter = null;
      Navigator.pop(context);
    }
  }

  Future<void> _onCancel() async {
    await _closeBottomSheet();
    if (_onCancelCB != null) {
      return await _onCancelCB();
    }
  }
}

class _IconAnimations {
  static final file =
      AssetFlare(bundle: rootBundle, name: 'assets/anim/nfc.flr');
  static const animWaiting  = 'nfc';
  static const animScanning = 'nfc';
  static const animSuccess  = 'checkmark';
  static const animError    = 'error';
}
