import 'package:flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import 'package:eosio_passid_mobile_app/screen/settings/network/network.dart';
import 'package:card_settings/card_settings.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:eosio_passid_mobile_app/screen/slideToSideRoute.dart';
import 'package:eosio_passid_mobile_app/utils/logging/loggerHandler.dart';
import 'package:eosio_passid_mobile_app/screen/flushbar.dart' as CustomFlushbar;
import 'package:eosio_passid_mobile_app/utils/storage.dart';
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
  bool enableLogging;
  bool switch_valid = true;
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Storage storage = Storage();
    widget.enableLogging = storage.loggingEnabled;

    return Container(
      child: Form(
        key: _formKey,
        child: CardSettings(
          children: <CardSettingsSection>[
            CardSettingsSection(
            header: CardSettingsHeader(label: 'Network'),
                children: <CardSettingsWidget>[
                  CardSettingsButton  (
                    bottomSpacing: 55,
                    label: "Node settings",
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
                showMaterialonIOS: true,
                divider: Divider(indent: 30, endIndent: 30,),
                header: CardSettingsHeader(label: 'Debug log'),
                children: <CardSettingsWidget>[
                  CardSettingsSwitch (
                    trueLabel: "",
                    falseLabel: "",
                    label: "Enable logging",
                    initialValue: widget.enableLogging,
                    validator:(value){
                      if (value && widget.switch_valid == false)
                        return "Please uncheck/check!";
                    },
                    onChanged: (value) async{
                      LoggerHandler loggerHandler = LoggerHandler();
                      if (value) {
                        bool isAllowed = await loggerHandler.startLoggingToAppMemory();
                        if (isAllowed == false)
                          setState(() {
                            widget.switch_valid = false;
                            widget.enableLogging = false;
                          });
                        else {
                          setState(() {
                            storage.loggingEnabled= true;
                            storage.save();
                            widget.switch_valid = true;
                            widget.enableLogging = value;
                          });
                        }
                      }
                      else
                        setState(() {
                          loggerHandler.stopLoggingToAppMemory(
                                  () => CustomFlushbar.showFlushbar(context, "Log", "Logging is stopped. Logs were successfully deleted.", Icons.info),
                                  () => CustomFlushbar.showFlushbar(context, "Log", "Logging is stopped. An error has occurred while deleting log files.", Icons.error)
                          );
                        });
                    },
                  ),
                  CardSettingsButton  (
                    label: "Share log",
                    enabled: widget.enableLogging,
                    visible: widget.enableLogging,
                    //visible: enableLogging != true? false: true,
                    onPressed: () {
                      LoggerHandler loggerHandler = LoggerHandler();
                      loggerHandler.export(showError: (){
                        CustomFlushbar.showFlushbar(context, "Logging", "Cannot export the log.", Icons.error);
                      });
                      //Share.shareFiles(['${directory.path}/image.jpg'], text: 'Great picture');
                    }),
                  CardSettingsButton  (
                    bottomSpacing: 55,
                    label: "Open log",
                    enabled: widget.enableLogging,
                    visible: widget.enableLogging,
                    onPressed: () {
                      LoggerHandler loggerHandler = LoggerHandler();
                      loggerHandler.export(open: true);
                    })
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

