import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import 'package:eosio_passid_mobile_app/screen/settings/network/network.dart';
import 'package:card_settings/card_settings.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:eosio_passid_mobile_app/screen/slideToSideRoute.dart';

class Settings extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        android: (_) => MaterialScaffoldData(resizeToAvoidBottomInset: false),
        ios: (_) => CupertinoPageScaffoldData(resizeToAvoidBottomInset: false),
        appBar: PlatformAppBar(
        title: Text("Settings"),
      ),
        body:SettingsScreen()
      );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Form(
      key: _formKey,
      child: CardSettings(
        children: <CardSettingsSection>[
      CardSettingsSection(
      header: CardSettingsHeader(label: 'Network'),
          children: <CardSettingsWidget>[
            CardSettingsButton  (
              label: "Server management",
              onPressed: (){
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsNetwork()));
            },),
            /*CardSettingsButton  (
              label: "Node  management",
              bottomSpacing: 3,
              onPressed: (){
                //Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsNetwork()));
              },
            ),*/
          ]
      ),

          CardSettingsSection(
              header: CardSettingsHeader(label: 'About'),
              children: <CardSettingsWidget>[
                CardSettingsInstructions(
                  text: "PassID" +
                      AndroidThemeST().getValues().themeValues["APP_DATA"]["COMPANY_NAME"] +
                      ' ('+ AndroidThemeST().getValues().themeValues["APP_DATA"]["YEAR_LAST_UPDATE"].toString() +  '), version:' +
                      AndroidThemeST().getValues().themeValues["APP_DATA"]["VERSION"],
                  ),
              ]
          ),


          ],
        )
    )
    );

  }
}

