//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'dart:math';

import 'package:dmrtd/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:passid/passid.dart';

import '../preferences.dart';
import '../srv_sec_ctx.dart';
import '../utils.dart';
import 'uiutils.dart';

bool _isValidUrl(String url) {
  final valid = Uri.tryParse(url) != null;
  return valid &&
      RegExp(r'^https?\:\/\/([0-9a-zA-Z\-\.]+)')
          .hasMatch(url); // regex is looking for "http(s)://x"
}

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key}) : super(key: key);
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _log = Logger('settings');
  static const String _urlRegex =
      r'^https?\:\/\/([0-9a-zA-Z\-\.]+)?(\:([0-9]{1,5})?)?(\/\S*)?';

  final _srvUrl  = TextEditingController();
  final _timeout = TextEditingController();
  final GlobalKey<State> _keyBusyIndicator =
      GlobalKey<State>(debugLabel: 'key_settings_screen_busy_indicator');

  @override
  void initState() {
    _srvUrl.text = Preferences.getServerUrl().toString();
    _timeout.text =
        Preferences.getConnectionTimeout().inSeconds.toRadixString(10);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          _saveSrvUrlInput();
          _saveTimeoutInput();
          return true;
        },
        child: Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            appBar: AppBar(
                elevation: 1.0,
                title: const Text('Settings'),
                backgroundColor: Theme.of(context).cardColor,
                leading: Container(width: 0,height: 0),
                actions: <Widget>[
                  IconButton(
                    iconSize: 40,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                    ),
                    onPressed: () => Navigator.maybePop(context),
                  )
                ]),
            body: Builder(
                builder: (context) => Container(
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
                              leading: Icon(Icons.settings_ethernet),
                              title: Text('Server settings'),
                            ),
                            _buildForm(context),
                            const SizedBox(height: 40),
                            _buildButton(context),
                            const SizedBox(height: 16),
                          ],
                        )))))));
  }

  void _showSnackBar(BuildContext scaffoldContext, String msg) {
    final snackBar = SnackBar(content: Text(msg, textAlign: TextAlign.center));
    Scaffold.of(scaffoldContext).showSnackBar(snackBar);
  }

  Padding _buildForm(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
        child: Form(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
          TextFormField(
              controller: _srvUrl,
              keyboardAppearance: Brightness.dark,
              decoration: const InputDecoration(labelText: 'Server URL'),
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.url,
              autofocus: false,
              onChanged: (url) {
                final urlrex = RegExp(_urlRegex).stringMatch(url);
                if (urlrex == null) {
                  url = 'http://';
                  if (_srvUrl.text.contains('https')) {
                    url = 'https://';
                  }
                  _srvUrl.text = url;
                  _srvUrl.selection = TextSelection.fromPosition(TextPosition(
                      offset: url.length)); // move input cursor to the end
                } else if (url != urlrex) {
                  _srvUrl.text = urlrex;
                  _srvUrl.selection = TextSelection.fromPosition(TextPosition(
                      offset: urlrex.length)); // move input cursor to the end
                }
              },
              onEditingComplete: () async {
                FocusScope.of(context).unfocus();
                await _saveSrvUrlInput();
              }),
          const SizedBox(height: 12),
          TextFormField(
            controller: _timeout,
            keyboardAppearance: Brightness.dark,
            decoration: const InputDecoration(labelText: 'Timeout (sec)'),
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter(RegExp(r'[1-9][0-9]*')),
              LengthLimitingTextInputFormatter(2)
            ],
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            autofocus: false,
            onEditingComplete: () async {
              FocusScope.of(context).unfocus();
              await _saveTimeoutInput();
            },
          ),
        ])));
  }

  Container _buildButton(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
        alignment: Alignment.center,
        child: Row(children: <Widget>[
          Expanded(
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              color: Theme.of(context).accentColor,
              textColor: Theme.of(context).cardColor,
              disabledTextColor: Theme.of(context).disabledColor,
              padding: const EdgeInsets.all(20.0),
              child: const Text(
                'TEST CONNECTION',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                await showBusyDialog(context, _keyBusyIndicator,
                    msg: 'Trying to connect to server ...');

                final srvUrl = await _saveSrvUrlInput();
                final timeout = await _saveTimeoutInput();

                final client =
                    ServerSecurityContext.getHttpClient(timeout: timeout)
                      ..badCertificateCallback = badCertificateHostCheck;

                final pidc = PassIdClient(srvUrl, httpClient: client);
                try {
                  await pidc.ping(Random().nextInt(0xffffffff));
                  _showSnackBar(context, 'Connection succeeded');
                } catch (e) {
                  _log.error(e);
                  _showSnackBar(context, 'Failed to connect to server!');
                }

                hideBusyDialog(_keyBusyIndicator,
                    syncWait: Duration(microseconds: 0));
              },
            ),
          )
        ]));
  }

  Future<Uri> _saveSrvUrlInput() async {
    var url = _srvUrl.text;
    if (!_isValidUrl(url)) {
      url = Preferences.defaltServerUrl.toString();
      _srvUrl.text = url;
    }
    final uri = Uri.parse(url);
    await Preferences.setServerUrl(uri);
    return uri;
  }

  Future<Duration> _saveTimeoutInput() async {
    var sto = _timeout.text;
    if (sto.isEmpty) {
      sto = Preferences.defaultTimeout.inSeconds.toRadixString(10);
      _timeout.text = sto;
    }

    final to = Duration(seconds: int.parse(sto));
    await Preferences.setConnectionTimeout(to);
    return to;
  }
}