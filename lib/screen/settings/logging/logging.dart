// removed unused import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// removed unused import
import 'package:port_mobile_app/utils/logging/loggerHandler.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:port_mobile_app/screen/flushbar.dart' as CustomFlushbar;
import 'package:card_settings/card_settings.dart';
import 'package:port_mobile_app/utils/storage.dart';
import 'package:port_mobile_app/screen/settings/custom/customCardSettingsButton.dart';
// removed unused import

// removed unused import
import 'package:port_mobile_app/screen/settings/logging/log_viewer.dart';
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
                            return null;
                          },
                          onChanged: (value) async {
                            final loggerHandler = LoggerHandler();
                            if (value) {
                              await loggerHandler.startLoggingToAppMemory();
                              setState(() {
                                widget.switch_valid = true;
                                widget.enableLogging = value;
                              });
                            } else {
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
                              setState(() {
                                LoggerHandlerInstance.logSensitiveData = false;
                              });
                            }
                          },
                        ),
                          CardSettingsSwitch(
                            trueLabel: "",
                            falseLabel: "",
                            enabled: widget.enableLogging,
                            visible: widget.enableLogging,
                            label: "Deep log",
                            initialValue: LoggerHandlerInstance.logSensitiveData,
                            onChanged: (value) async {
                              LoggerHandlerInstance.logSensitiveData = value;
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
                            }),
                        CustomCardSettingsButton(
                            bottomSpacing: 0.0,
                            label: "Open log",
                            enabled: widget.enableLogging,
                            visible: widget.enableLogging,
                            onPressed: () {
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const LogViewerScreen()));
                            }),
                      ]),
                ]))));
  }
}
