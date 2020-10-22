import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';

void showFlushbar(BuildContext context, String title, String message, IconData icon, {int duration = 5})
{
  if (icon == null)
    icon = Icons.warning;

  Flushbar(
      icon: Icon(
        icon,
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
  )..show(context);
}