import 'package:eosio_passid_mobile_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import 'package:eosio_passid_mobile_app/screen/settings/network/networkList.dart';
import 'package:eosio_passid_mobile_app/screen/settings/logging/logging.dart';
import 'package:card_settings/card_settings.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/screen/settings/custom/customCardSettingsButton.dart';
import 'package:eosio_passid_mobile_app/screen/settings/custom/customCardSettings.dart';
import 'package:eosio_passid_mobile_app/screen/settings/custom/CustomCardSettingsSection.dart';
import 'package:eosio_passid_mobile_app/screen/settings/network/server/updateCloud.dart';
import 'package:eosio_passid_mobile_app/screen/qr/QRscreen.dart';
import 'package:share/share.dart';

class Settings extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        material: (_,__) => MaterialScaffoldData(resizeToAvoidBottomInset: false),
        cupertino: (_,__) => CupertinoPageScaffoldData(resizeToAvoidBottomInset: false),
        appBar: PlatformAppBar(
        title: Text("Settings"),
      ),
        body:SettingsScreen()
      );
  }
}

class SettingsScreen extends StatefulWidget {
  bool enableLogging = true;
  bool switch_valid = true;
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Storage storage = Storage();
    widget.enableLogging = storage.loggingEnabled;

    return Container(
      child: Form(
        key: _formKey,
        child: CustomCardSettings(
          children: <CardSettingsSection>[
            CardSettingsSection(
              divider: Divider(indent: 30, endIndent: 30),
              header: CardSettingsHeader(label: "Connections"),
                children: <CardSettingsWidget>[
                  CustomCardSettingsButton  (
                    label: "Blockchain networks",
                    onPressed: (){
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SettingsNetworkList()));
                  },),
                  CustomCardSettingsButton  (
                    label: "Networks",
                    onPressed: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SettingsUpdateCloud(networkTypeServer: NetworkTypeServer.MAIN_SERVER)));
                    },),
                ]
            ),
            CardSettingsSection(
                header: CardSettingsHeader(label: 'General'),
                divider: Divider(indent: 30, endIndent: 30),
                children: <CardSettingsWidget>[
                  CustomCardSettingsButton (
                      bottomSpacing: 5,
                      label: "Debug log",
                  onPressed: (){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoggingScreen()));
                  }),
                  CustomCardSettingsButton (
                      bottomSpacing: 5,
                      label: "Scanning QR",
                      onPressed: (){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => QRscreen()));
                      })
              ]
            ),
            CardSettingsSection(
                header: CardSettingsHeader(label: 'About'),
                children: <CardSettingsWidget>[
                  CardSettingsInstructions(
                    text: "Port" +
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