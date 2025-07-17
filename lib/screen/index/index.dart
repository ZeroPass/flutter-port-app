import 'dart:async';

import 'package:logging/logging.dart';
import 'package:port_mobile_app/screen/nfc/uie/uiutils.dart';
import 'package:port_mobile_app/screen/qr/readQR.dart';
import 'package:port_mobile_app/screen/qr/structure.dart';
import 'package:port_mobile_app/screen/requestType.dart';
import 'package:port_mobile_app/screen/settings/settings.dart';
import 'package:port_mobile_app/services/deep_link_service.dart';
//import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:port_mobile_app/screen/theme.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart';
import 'package:app_links/app_links.dart';
import '../slideToSideRoute.dart';

final _log = Logger('DeepLinkService');

class Index extends StatefulWidget {
  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks(context);
  }

  void _handleDynamicLink(BuildContext context, Uri? link) {
    if (link != null) {
      if (_handleAndSaveData(link.queryParameters)){
        var path = "/homeMagnetLink";
        _log.info('Going to steppeer on ${path}');
        Navigator.pushNamed(context, path);
      }
    }
  }

  bool _handleAndSaveData(Map<String, dynamic> data) {
    try {
      //translate data from shorter(v2) to longer(v1) format
      Map<String, dynamic> dataLong = QRstructure.shortToLong(data);
      var qr = QRserverStructure.fromJson(dataLong);
      ReadQR.saveToDatabase(qr);
      return true;
    } catch (e) {
      _log.info("deep link.handleAndSaveData: Exception: " + e.toString());
      return false;
    }
  }

  Future<void> _initDeepLinks(BuildContext context) async {
    _linkSubscription = AppLinks().uriLinkStream.listen((uri) {
      _log.info('onAppLink: $uri');
      _log.info('queryParameters: ${uri.queryParameters}');
      _handleDynamicLink(context, uri);
      //var queryParams = uri.queryParameters;
      //var qr = QRserverStructure.fromJson(queryParams);
      //var wer = 9;
    });
  }

  @override
  Widget build(BuildContext context) {
    //this._initDeepLinks(context);
    return IndexScreen();
  }
}

class IndexScreen extends StatefulWidget {
  @override
  _IndexScreenState createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  @override
  Widget build(BuildContext context) {
    showNavigationBar();
    var _SCAFFOLD_KEY = GlobalKey<ScaffoldState>();

    return PlatformScaffold(
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            toolbarHeight: 30,
            actions: [
              PlatformIconButton(
                  padding: EdgeInsets.all(0),
                  materialIcon: Icon(Icons.settings_rounded,
                      size: 30.0, color: Colors.grey),
                  material: (_, __) =>
                      MaterialIconButtonData(color: Colors.green,tooltip: 'Settings'),
                  onPressed: () {
                    final page = Settings();
                    Navigator.of(context).push(SlideToSideRoute(page));
                  })
            ]
            ),
        cupertino: (_, __) => CupertinoNavigationBarData(
            border: Border(),
            backgroundColor: Colors.white,
            trailing: PlatformIconButton(
              cupertino: (_, __) => CupertinoIconButtonData(
                    icon: Icon(Icons.settings_rounded,
                        color: Colors.grey, size: 30),
                    padding: EdgeInsets.all(0),
                  ),
              //materialIcon: Icon(Icons.settings_rounded,
              //    size: 30.0, color: Colors.white),
              material: (_, __) =>
                  MaterialIconButtonData(color: Colors.green,tooltip: 'Settings'),
              onPressed: () {
                final page = Settings();
                Navigator.of(context).push(SlideToSideRoute(page));
              }))
      ),
      body:
          Column(
        //mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            // child: Container(
            //     width: 45,
            //     height: 45,
            //     color: Colors.green,
            //     // decoration: BoxDecoration(
            //     //   color: Color(0x00EEEEEE),
            //     // ),
            //     child: PlatformIconButton(
            //         // cupertino: (_, __) => CupertinoIconButtonData(
            //         //       icon: Icon(Icons.settings_rounded,
            //         //           color: Colors.grey, size: 30),
            //         //       padding: EdgeInsets.all(0),
            //         //     ),
            //         materialIcon: Icon(Icons.settings_rounded,
            //             size: 30.0, color: Colors.grey),
            //         material: (_, __) =>
            //             MaterialIconButtonData(tooltip: 'Settings'),
            //         onPressed: () {
            //           final page = Settings();
            //           Navigator.of(context).push(SlideToSideRoute(page));
            //         })),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  height: MediaQuery.of(context).size.width /3,
                  child: SvgPicture.asset(
                      'assets/images/port.link.logo.text.svg',
                      semanticsLabel: 'Logo')),
              Container(
                  height: MediaQuery.of(context).size.height / 2.5,
                  alignment: Alignment.center,
                  child: SelectableText(
                    'Welcome to the Port app!\n' +
                        'Locate the Port QR code and scan it.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        color: AndroidThemeST()
                            .getValues()
                            .themeValues["STEPPER"]["STEP_SCAN"]["COLOR_TEXT"]),
                  )),
              Container(
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          makeButton(
                              context: context,
                              margin: EdgeInsets.only(
                                  left: 30.0, right: 30.0, bottom: 65),
                              text: 'Scan QR code',
                              color: AndroidThemeST()
                                      .getValues()
                                      .themeValues["INDEX_SCREEN"]
                                  ["COLOR_BACKGROUND"],
                              onPressed: () async {
                                Navigator.of(context).pushNamed('/QR');
                              })
                        ],
                      ))),
            ],
          )
        ],
      ),
      //),
      //)
    );
  }
}
