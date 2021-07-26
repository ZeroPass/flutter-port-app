import 'package:eosio_port_mobile_app/constants/constants.dart';
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

import '../slideToSideRoute.dart';


class Index extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
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
      // ignore: unawaited_futures
      //Navigator.of(context).pushNamedAndRemoveUntil(deepLink.path, (Route<dynamic> route) => false);
      Navigator.pushNamed(context, deepLink.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    this.initDynamicLinks(context);
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
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/port_icon.png',
                      width: MediaQuery.of(context).size.width * 0.7,
                      fit: BoxFit.fitHeight,
                    )
                  ],
                ),
              ),
              Expanded(
                child:Container(
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,

                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 25),
                              child: CustomButton(
                                callbackOnPressed: () async {
                                  Navigator.of(context).pushNamed('/QR');
                                  //SystemChrome.setEnabledSystemUIMode(
                                  //    SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
                                },
                                title: 'Scan QR code',
                                backgroundColor: Color(0xFFA58157),
                              ),
                            )

                  ],
                )
                )
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}