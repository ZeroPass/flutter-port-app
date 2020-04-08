//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:dmrtd/dmrtd.dart';
import 'package:dmrtd/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:open_settings/open_settings.dart';
import 'package:passid/passid.dart';

import '../passport_scanner.dart';
import '../preferences.dart';
import '../srv_sec_ctx.dart';
import '../utils.dart';
import 'efdg1_dialog.dart';
import 'success_screen.dart';
import 'uiutils.dart';


enum AuthnAction { register, login }

class AuthnScreen extends StatefulWidget {
  final AuthnAction _action;
  AuthnScreen(this._action, {Key key}) : super(key: key);
  _AuthnScreenState createState() => _AuthnScreenState(_action);
}


class _AuthnScreenState extends State<AuthnScreen>
    with WidgetsBindingObserver {
  _AuthnScreenState(this._action);

  final AuthnAction _action;
  final _log = Logger('action.screen');
  PassIdClient _client;

  var _isNfcAvailable = false;
  var _isScanningMrtd = false;

  final GlobalKey _keyNfcAlert = GlobalKey();
  bool _isBusyIndecatorVisible = false;
  final GlobalKey<State> _keyBusyIndicator =
      GlobalKey<State>(debugLabel: 'key_action_screen_busy_indicator');

  // Data needed fo PassId protocol
  ProtoChallenge _challenge;
  final _authnData = Completer<AuthnData>();

  // mrz data
  final _mrzData = GlobalKey<FormState>();
  final _docNumber = TextEditingController();
  final _dob = TextEditingController(); // date of birth
  final _doe = TextEditingController(); // date of doc expiry

  // UI components
  IconButton _settingsButton;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final httpClient = ServerSecurityContext
      .getHttpClient(timeout: Preferences.getConnectionTimeout())
      ..badCertificateCallback = badCertificateHostCheck;

     _updateNfcStatus().then((value) async {
        if(!_isNfcAvailable) {
          await _showNfcAlert();
          if(!_isNfcAvailable) {
            return;
          }
        }
        _showBusyIndicator().then((value) async {
          try {
            // Init PassIdClient
            _client = PassIdClient(Preferences.getServerUrl(), httpClient: httpClient);
            _client.onConnectionError  = _handleConnectionError;
            _client.onDG1FileRequested = _handleDG1Request;

            // Execute authn action on passId client
            switch(_action) {
              case AuthnAction.register:
                await _client.register((challenge) async {
                  _hideBusyIndicator();
                  return _getAuthnData(challenge).then((data) {
                    _showBusyIndicator(msg: 'Signing up ...');
                     return data;
                  });
                });
                break;
              case AuthnAction.login:
              await _client.login((challenge) async {
                  _hideBusyIndicator();
                  return _getAuthnData(challenge).then((data) {
                    _showBusyIndicator(msg: 'Logging in ...');
                     return data;
                  });
              });
              break;
            }

            // Request greeting from server and on successful
            // response show SuccessScreen
            final srvMsg = await _client.requestGreeting();
            await _hideBusyIndicator(syncWait: Duration(seconds: 0));
            Navigator.pushReplacement(
              context, CupertinoPageRoute(
                builder: (context) => SuccessScreen(_action, _client.uid, srvMsg),
            ));
          }
          catch(e) {
            String alertTitle;
            String alertMsg;
            if (e is SocketException) {} // should be already handled through _handleConnectionError callback
            else if(e is PassIdError) {
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
                    'MAIN MENU',
                    style: TextStyle(
                        color: Theme.of(context).errorColor,
                        fontWeight: FontWeight.bold),
                  ))
              ]);
            }

            // Return to main menu
            _goToMain();
          }
        });
     });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _client?.disposeChallenge();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _log.debug('App resumed, updating NFC status');
      await _updateNfcStatus();
      if(!_authnData.isCompleted && !_isNfcAvailable) {
        _log.debug('NFC is disabled showing alert');
        _showNfcAlert();
      }
      else {
        _hideNfcAlert();
      }
    }
  }

  @override
  void didChangeLocales(List<Locale> locale) {
    super.didChangeLocales(locale);
  }

  @override
  Widget build(BuildContext context) {
    _settingsButton = settingsButton(
      context,
      onWillPop: () {
        final timeout = Preferences.getConnectionTimeout();
        final url = Preferences.getServerUrl();
        _log.verbose('Updating client timeout=$timeout url=$url');
        _client.timeout = timeout;
        _client.url     = url;
    });

    return Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            appBar: AppBar(
                elevation: 1.0,
                title: Text(_action == AuthnAction.register ? 'Sign Up' : 'Login'),
                backgroundColor: Theme.of(context).cardColor,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  tooltip: 'Back',
                  onPressed: () => _goToMain(),
                ),
                actions: <Widget>[
                 _settingsButton
                ],
            ),
            body: Container(
                //height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                ),
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Card(
                        elevation: 1.0,
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(color: Color(0xff0c0c0c)),
                            borderRadius: BorderRadius.circular(5.0)),
                        child: SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                              const ListTile(
                                leading: Icon(Icons.nfc),
                                title: Text('Passport information'),
                              ),
                              const SizedBox(height: 20),
                              _buildForm(context),
                              const SizedBox(height: 20),
                              makeButton(
                                context: context,
                                text: 'SCAN PASSPORT',
                                disabled: _disabledInput(),
                                visible: _mrzData.currentState?.validate() ?? false,
                                onPressed: _scanPassport,
                              ),
                              const SizedBox(height: 16),
                            ]))))));
  }

  Padding _buildForm(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
        child: Form(
          key: _mrzData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              makeButton(
                context: context,
                text: 'FILL FROM STORAGE',
                padding: null,
                disabled: _disabledInput(),
                visible:  Preferences.getDBAKeys() != null && !(_mrzData.currentState?.validate() ?? false),
                onPressed: () {
                  final keys = Preferences.getDBAKeys();
                  if(keys != null) {
                    setState(() {
                      _docNumber.text = keys.mrtdNumber;
                      final locale = getLocaleOf(context);
                      _dob.text = formatDate(keys.dateOfBirth, locale: locale);
                      _doe.text = formatDate(keys.dateOfExpiry, locale: locale);
                    });
                  }
                }
              ),
              const SizedBox(height: 20),
              TextFormField(
                enabled: !_disabledInput(),
                controller: _docNumber,
                keyboardAppearance: Brightness.dark,
                decoration: const InputDecoration(labelText: 'Passport number'),
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter(RegExp(r'[A-Z0-9]+')),
                  LengthLimitingTextInputFormatter(14)
                ],
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.characters,
                autofocus: true,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter passport number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                  enabled: !_disabledInput(),
                  controller: _dob,
                  decoration: const InputDecoration(labelText: 'Date of Birth'),
                  autofocus: false,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please select Date of Birth';
                    }
                    return null;
                  },
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    // Can pick date which dates 15 years back or more
                    final now = DateTime.now();
                    final firstDate =
                        DateTime(now.year - 90, now.month, now.day);
                    final lastDate =
                        DateTime(now.year - 15, now.month, now.day);
                    final initDate = _getDOBDate();
                    final date = await pickDate(context, firstDate,
                        initDate ?? lastDate, lastDate);

                    FocusScope.of(context).requestFocus(FocusNode());
                    if (date != null) {
                      final locale = getLocaleOf(context);
                      _dob.text = formatDate(date, locale: locale);
                    }
                  }),
              const SizedBox(height: 12),
              TextFormField(
                enabled: !_disabledInput(),
                controller: _doe,
                decoration:
                    const InputDecoration(labelText: 'Date of Expiry'),
                autofocus: false,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please select Date of Expiry';
                  }
                  return null;
                },
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  // Can pick date from tomorrow and up to 10 years
                  final now = DateTime.now();
                  final firstDate =
                      DateTime(now.year, now.month, now.day + 1);
                  final lastDate =
                      DateTime(now.year + 10, now.month + 6, now.day);
                  final initDate = _getDOEDate();
                  final date = await pickDate(context, firstDate,
                      initDate ?? firstDate, lastDate);

                  FocusScope.of(context).requestFocus(FocusNode());
                  if (date != null) {
                    final locale = getLocaleOf(context);
                    _doe.text = formatDate(date, locale: locale);
                  }
              }),

            ],
          ),
        ));
  }

  bool _disabledInput() {
    return _isScanningMrtd || !_isNfcAvailable;
  }

  Future<AuthnData> _getAuthnData(final ProtoChallenge challenge) {
    _challenge = challenge;
    return _authnData.future;
  }
  DateTime _getDOBDate() {
    if (_dob.text.isEmpty) {
      return null;
    }
    return DateFormat.yMd().parse(_dob.text);
  }

  DateTime _getDOEDate() {
    if (_doe.text.isEmpty) {
      return null;
    }
    return DateFormat.yMd().parse(_doe.text);
  }

  void _goToMain() {
    Navigator.popUntil(context, (route) {
      if(route.settings.name == '/') {
        return true;
      }
      return false;
    });
  }

  // Returns true if client should retry connection action
  // otherwise false.
  Future<bool> _handleConnectionError(final SocketException e) async {
    String title;
    String msg;
    Function settingsAction;

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none ||
     !await testConnection()) {
      settingsAction = () => OpenSettings.openWIFISetting();
      title = 'No Internet connection';
      msg   = 'Internet connection is required in order to '
              "${_action == AuthnAction.register ? "sign up" : "login"}.";
    }
    else {
      settingsAction = () => _settingsButton.onPressed();
      title = 'Connection error';
      msg   = 'Failed to connect to server.\n'
              'Check server connection settings.';
    }

    return showAlert<bool>(context,
      Text(title),
      Text(msg),
      [
        FlatButton(
          child: Text('MAIN MENU',
            style: TextStyle(
                color: Theme.of(context).errorColor,
                fontWeight: FontWeight.bold)),
          onPressed: () => Navigator.pop(context, false)
        ),
        FlatButton(
            child: const Text(
            'SETTINGS',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: settingsAction,
        ),
        FlatButton(
          child: const Text(
            'RETRY',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () => Navigator.pop(context, true)
        )
      ]
    );
  }

  // Returns true if client should retry connection action
  // otherwise false.
  Future<bool> _handleDG1Request(final EfDG1 dg1) async {
    _log.debug('Handling request for file EfDG1');
    return showEfDG1Dialog(
      context,
      dg1,
      message: 'Server requested additional data',
      actions: [
        makeButton(
          context: context,
          text: 'SEND',
          margin: null,
          onPressed: () {
            Navigator.pop(context, true);
        }),
        makeButton(
          context: context,
          text: 'LOG OUT',
          color: Theme.of(context).errorColor,
          margin: null,
          onPressed: () {
            Navigator.pop(context, false);
        }),
      ]
    );
  }

  Future<void> _showBusyIndicator({String msg = 'Please Wait ....'}) async {
    await _hideBusyIndicator();
    await showBusyDialog(context, _keyBusyIndicator, msg: msg);
    _isBusyIndecatorVisible = true;
  }

  Future<void> _hideBusyIndicator({ Duration syncWait = const Duration(milliseconds: 200)}) async {
    if (_keyBusyIndicator.currentContext != null) {
      await hideBusyDialog(_keyBusyIndicator,
          syncWait: syncWait);
      _isBusyIndecatorVisible = false;
    } else if (_isBusyIndecatorVisible) {
      await Future.delayed(const Duration(milliseconds: 200), () async {
        await _hideBusyIndicator();
      });
    }
  }

  Future<bool> _showNfcAlert() async {
    if (_keyNfcAlert.currentContext == null) {
      await showAlert(context,
        Text('NFC disabled'),
        Text('NFC adapter is required to be enabled.'),
        [
          FlatButton(
              child: Text('MAIN MENU',
                  style: TextStyle(
                      color: Theme.of(context).errorColor,
                      fontWeight: FontWeight.bold)),
            onPressed: () => _goToMain()
          ),
          FlatButton(
              child: const Text(
              'SETTINGS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => OpenSettings.openMainSetting(),
          )
        ],
        key: _keyNfcAlert
      );
    }
  }

  void _hideNfcAlert() async {
    if (_keyNfcAlert.currentContext != null) {
      Navigator.of(_keyNfcAlert.currentContext, rootNavigator: true).pop();
    }
  }

  Future<void> _scanPassport() async {
    assert(_challenge != null);
    try {
      setState(() {
        _isScanningMrtd = true;
      });

      final dbaKeys = DBAKeys(_docNumber.text, _getDOBDate(), _getDOEDate());
      final data = await PassportScanner(
        context: context,
        challenge: _challenge,
        action: _action
      ).scan(dbaKeys);
      await Preferences.setDBAKeys(dbaKeys);  // Save MRZ data
      _authnData.complete(data);
    } catch(e) {} // ignore: empty_catches
    finally {
      setState(() {
        _isScanningMrtd = false;
      });
    }
  }

  Future<void> _updateNfcStatus() async {
    bool isNfcAvailable;
    try {
      NfcStatus status = await NfcProvider.nfcStatus;
      isNfcAvailable = status == NfcStatus.enabled;
    } on PlatformException {
      isNfcAvailable = false;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _isNfcAvailable = isNfcAvailable;
    });
  }
}