import 'package:eosio_port_mobile_app/constants/constants.dart';
import 'package:eosio_port_mobile_app/screen/nfc/uie/uiutils.dart';
import 'package:eosio_port_mobile_app/screen/qr/readQR.dart';
import 'package:eosio_port_mobile_app/screen/qr/structure.dart';
import 'package:eosio_port_mobile_app/screen/settings/settings.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:eosio_port_mobile_app/screen/theme.dart';
import 'package:eosio_port_mobile_app/screen/settings/network/networkList.dart';
import 'package:eosio_port_mobile_app/screen/customButton.dart';
import 'package:eosio_port_mobile_app/screen/main/stepperIndex.dart';
import 'package:card_settings/card_settings.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../slideToSideRoute.dart';


class Index extends StatelessWidget {


  bool handleAndSaveData(Map<String, dynamic> data){
    try{
      var qr = QRserverStructure.fromJson(data);
      ReadQR.saveToDatabase(qr);
      return true;
    }
    catch(e) {
      print("Dynamic link.handleAndSaveData: Exception: " + e.toString());
      return false;
    }
  }

  Future<void> initDynamicLinks(BuildContext context) async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
          final Uri? deepLink = dynamicLink?.link;

          if (deepLink != null) {
            Navigator.of(context).pushNamedAndRemoveUntil(deepLink.path, (Route<dynamic> route) => false);
            //Navigator.pushNamed(context, deepLink.path);
          }
        }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();

    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      if (handleAndSaveData(deepLink.queryParameters))
        Navigator.pushNamed(context, deepLink.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    this.initDynamicLinks(context);
    return IndexScreen();
  }
}

class IndexScreen extends StatefulWidget {
  @override
  _IndexScreenState createState() => _IndexScreenState();
}


class _IndexScreenState extends State<IndexScreen> {

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    showNavigationBar();
    var _SCAFFOLD_KEY = GlobalKey<ScaffoldState>();

    return PlatformScaffold(
      appBar: PlatformAppBar(
        material: (_, __) =>MaterialAppBarData(toolbarHeight: 0),
        cupertino: (_, __) => CupertinoNavigationBarData(backgroundColor: Colors.transparent,
        border: Border() /*all borders removed*/),
      ),
    body:Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 1,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Color(0x00EEEEEE),
                  ),
                  child: PlatformIconButton(
                          cupertino: (_,__) => CupertinoIconButtonData(
                            icon: Icon(
                                Icons.settings_outlined,
                                color: Colors. grey,
                                size: 30
                            ),
                            padding: EdgeInsets.all(0),
                          ),
                          materialIcon: Icon(Icons.settings_outlined, size: 30.0, color: Colors.grey),
                          material: (_,__) => MaterialIconButtonData(tooltip: 'Settings'),
                          onPressed: () {
                            final page = Settings();
                            Navigator.of(context).push(SlideToSideRoute(page));
                          }
                      )
                ),
              ),
              Expanded(
                child: Container(
                        //color: Colors.green,
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.only(top: 25),
                        //margin: EdgeInsets.only(top:25),
                        width: MediaQuery.of(context).size.width/3,
                        height: MediaQuery.of(context).size.height/2,
                        child: SvgPicture.asset(
                          'assets/images/port.link.logo.text.svg',
                          semanticsLabel: 'Logo'
                    )
                ),

              ),
          Flexible(
            child:Container(
                  height: MediaQuery.of(context).size.height/6,
                  //color: Colors.amber,
                  alignment: Alignment.center,
                  child: SelectableText(
                  'Welcome to the Port app!\n' +
                  'Locate the Port QR code and scan it.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,

                    color: AndroidThemeST().getValues().themeValues["STEPPER"]
                    ["STEP_SCAN"]["COLOR_TEXT"]),
              ))),
              Container(
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,

                          children: [
                            makeButton(
                                context: context,
                                margin: EdgeInsets.only(left: 30.0, right: 30.0, bottom: 25),
                                text: 'Scan QR code',
                                onPressed: () async {
                                  Navigator.of(context).pushNamed('/QR');
                                }
                            )

                  ],
                )
                )
                ),

            ],
          ),
        ),
      )
    );
  }
}