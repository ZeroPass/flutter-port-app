import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';

BuildContext STATIC_BUILD_CONTEXT = null;

void setGlobalStaticBuildContext(BuildContext context)
{
  STATIC_BUILD_CONTEXT = context;
}

void showFlushbar(String title, String message, {int duration = 5})
{
  if (STATIC_BUILD_CONTEXT == null)
    throw Exception("Global variable 'STATIC_BUILD_CONTEXT' is not set");

  Flushbar(
      icon: Icon(
        Icons.warning,
        size: 28.0,
        color: Colors.white,
      ),
      titleText: Text(title,
          style: TextStyle(color: AndroidThemeST().getValues().themeValues["FLUSHBAR"]["COLOR_TEXT"], fontWeight: FontWeight.bold)),
      messageText: Text(message,
          style: TextStyle(color: AndroidThemeST().getValues().themeValues["FLUSHBAR"]["COLOR_TEXT"])),
      duration:  Duration(seconds: duration),
      backgroundColor: AndroidThemeST().getValues().themeValues["FLUSHBAR"]["COLOR_BACKGROUND"],
      flushbarStyle: FlushbarStyle.FLOATING

  )..show(STATIC_BUILD_CONTEXT);
}