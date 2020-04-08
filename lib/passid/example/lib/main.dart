//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'dart:io';

import 'package:dmrtd/dmrtd.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:passide/preferences.dart';
import 'package:flutter/services.dart';

import 'uie/authn_screen.dart';
import 'uie/home_page.dart';
import 'uie/uiutils.dart';
import 'srv_sec_ctx.dart';

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print(
        '${record.loggerName} ${record.level.name}: ${record.time}: ${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.init();
  final rawSrvCrt = await rootBundle.load('assets/certs/passid_srv.cer');
  ServerSecurityContext.init(rawSrvCrt.buffer.asUint8List());
  runApp(PassIdeApp());
}

class PassIdeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PassIDe',
      localizationsDelegates: <LocalizationsDelegate>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      theme: ThemeData(
          disabledColor: Colors.black38,
          applyElevationOverlayColor: true,
          primaryColor: const Color(0xffeaeaea),
          accentColor: const Color(0xffbb86fc),
          errorColor: const Color(0xffcf6679),
          cardColor: const Color(0xff121212),
          snackBarTheme: const SnackBarThemeData(
              backgroundColor: Color(0xff292929),
              contentTextStyle: TextStyle(color: Color(0xffeaeaea))),
          backgroundColor: const Color(0xff121212),
          accentColorBrightness: Brightness.dark,
          brightness: Brightness.dark,
          primaryColorBrightness: Brightness.dark,
          inputDecorationTheme: InputDecorationTheme(
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.87), width: 2.0),
              ))),
      home: PassIdeWidget(),
    );
  }
}

class PassIdeWidget extends StatefulWidget {
  @override
  _PassIdeWidgetState createState() => _PassIdeWidgetState();
}

class _PassIdeWidgetState extends State<PassIdeWidget>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]); // hide status bar
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _checkNfcIsSupported();
  }

  void gotoLogin() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AuthnScreen(AuthnAction.login),
      ),
    );
  }

  void gotoSignup() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AuthnScreen(AuthnAction.register),
      ),
    );
  }

  void _checkNfcIsSupported() {
    NfcProvider.nfcStatus.then((status) {
      if (status == NfcStatus.notSupported ||
          (Platform.isIOS && status == NfcStatus.disabled)) {
        showAlert(
            context,
            Text('NFC not supported'),
            Text(
                "This device doesn't support NFC.\nNFC is required to use this app."),
            [
              FlatButton(
                  child: Text('EXIT',
                      style: TextStyle(
                          color: Theme.of(context).errorColor,
                          fontWeight: FontWeight.bold)),
                  onPressed: () {
                    if (Platform.isIOS) {
                      exit(0);
                    } else {
                      SystemNavigator.pop(animated: true);
                    }
                  })
            ]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Container(
            height: MediaQuery.of(context).size.height,
            child: HomePage(context, gotoSignup, gotoLogin)));
  }
}
