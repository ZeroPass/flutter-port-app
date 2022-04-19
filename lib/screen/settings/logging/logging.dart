import 'package:dmrtd/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eosio_port_mobile_app/screen/theme.dart';
import 'package:eosio_port_mobile_app/utils/logging/loggerHandler.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_port_mobile_app/screen/flushbar.dart' as CustomFlushbar;
import 'package:card_settings/card_settings.dart';
import 'package:eosio_port_mobile_app/utils/storage.dart';
import 'package:eosio_port_mobile_app/screen/settings/custom/customCardSettingsButton.dart';
import "dart:io" show Platform;

import 'package:logging/logging.dart';

class LoggingScreen extends StatefulWidget {
  late bool enableLogging;
  late bool switch_valid;

  LoggingScreen(){
    enableLogging = false;
    switch_valid = true;
  }

  @override
  _LoggingScreen createState() => _LoggingScreen();
}

class _LoggingScreen extends State<LoggingScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _LoggingScreen();

  @override
  Widget build(BuildContext context) {
    Storage storage = Storage();
    widget.enableLogging = storage.loggingEnabled;

    return Container(
        child: PlatformScaffold(
            material: (_, __) =>
                MaterialScaffoldData(resizeToAvoidBottomInset: false),
            cupertino: (_, __) =>
                CupertinoPageScaffoldData(resizeToAvoidBottomInset: false),
            appBar: PlatformAppBar(
              title: Text("Debug log"),
            ),
            body: Form(
                key: _formKey,
                child: CardSettings(
                  cardless: true,
                  margin: EdgeInsets.all(0.0),
                    children: <CardSettingsSection>[
                  CardSettingsSection(
                      showMaterialonIOS: true,
                      divider: Divider(
                        //indent: 20,
                        //endIndent: 20,
                        thickness: 0,
                        color: Colors.white,
                      ),
                      children: <CardSettingsWidget>[
                        CardSettingsSwitch(
                          trueLabel: "",
                          falseLabel: "",
                          label: "Enable logging",
                          initialValue: widget.enableLogging,
                          validator: (value) {
                            if (/*value &&*/ widget.switch_valid == false)
                              return "Please uncheck/check!";
                          },
                          onChanged: (value) async {
                            LoggerHandler loggerHandler = LoggerHandler();
                            if (value) {
                              bool isAllowed =
                                  await loggerHandler.startLoggingToAppMemory();
                              if (isAllowed == false)
                                setState(() {
                                  widget.switch_valid = false;
                                  widget.enableLogging = false;
                                });
                              else {
                                setState(() {
                                  storage.loggingEnabled = true;
                                  storage.save();
                                  widget.switch_valid = true;
                                  widget.enableLogging = value;
                                });
                              }
                            } else
                              setState(() {
                                Logger.root.logSensitiveData = false;
                                loggerHandler.stopLoggingToAppMemory(
                                    () => CustomFlushbar.showFlushbar(
                                        context,
                                        "Log",
                                        "Logging stopped. All logs were successfully deleted.",
                                        Icons.info),
                                    () => CustomFlushbar.showFlushbar(
                                        context,
                                        "Log",
                                        "Logging stopped. An error has occurred while deleting log files.",
                                        Icons.error));
                              });
                          },
                        ),
                          CardSettingsSwitch(
                            trueLabel: "",
                            falseLabel: "",
                            enabled: widget.enableLogging,
                            visible: widget.enableLogging,
                            label: "Deep log", //Logger.root.logSensitiveData = true
                            initialValue: Logger.root.logSensitiveData,
                            onChanged: (value) async {
                              Logger.root.logSensitiveData = value;
                              if (value) {
                                setState(() {
                                  CustomFlushbar.showFlushbar(
                                      context,
                                      "Deep log",
                                      "Logging of sensitive data enabled (auto disabled after app restart).",
                                      Icons.info);
                                });
                              } else
                                setState(() {
                                  CustomFlushbar.showFlushbar(
                                      context,
                                      "Deep log",
                                      "Logging of sensitive data disabled.",
                                      Icons.info);
                                });
                            },
                          ),
                        CustomCardSettingsButton(
                            bottomSpacing: 0.0,
                            label: "Share log",
                            enabled: widget.enableLogging,
                            visible: widget.enableLogging,
                            //visible: enableLogging != true? false: true,
                            onPressed: () {
                              LoggerHandler loggerHandler = LoggerHandler();
                              loggerHandler.export(showError: () {
                                CustomFlushbar.showFlushbar(context, "Logging",
                                    "Cannot export the log.", Icons.error);
                              });
                              //Share.shareFiles(['${directory.path}/image.jpg'], text: 'Great picture');
                            }),
                        CustomCardSettingsButton(
                            bottomSpacing: 0.0,
                            label: "Open log",
                            enabled: widget.enableLogging,
                            visible: widget.enableLogging,
                            onPressed: () {
                              LoggerHandler loggerHandler = LoggerHandler();
                              loggerHandler.export(open: true);
                            }),
                      ]),
                ]))));
  }
}
