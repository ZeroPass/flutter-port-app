//  Created by Crt Vavros, copyright © 2021 ZeroPass. All rights reserved.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'load_indicator.dart';

String formatDate(DateTime date, {Locale? locale}) {
  late String strDate;
  if (date != null) {
    strDate = DateFormat.yMd(locale?.languageCode).format(date);
  }
  return strDate;
}

/// Returns [Locale] or null.
Locale? getLocaleOf(BuildContext ctx) {
  return Localizations.maybeLocaleOf(ctx);
}

Container makeButton(
    {required BuildContext context,
      required String text,
      bool disabled = false,
      bool visible = true,
      Function? onPressed,
      Color? color,
      padding = const EdgeInsets.all(20.0),
      margin = const EdgeInsets.only(left: 30.0, right: 30.0)}) {
  return !visible
      ? Container()
      : Container(
      width: MediaQuery.of(context).size.width,
      margin: margin,
      alignment: Alignment.center,
      child: Row(children: <Widget>[
        Expanded(
            child: TextButton(
                //ok shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                //removed color: color ?? Theme.of(context).accentColor,
                //OK textColor: Theme.of(context).cardColor,
                //removed disabledTextColor: Theme.of(context).disabledColor,
                //OK padding: padding,
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(padding),
                  backgroundColor: MaterialStateProperty.all<Color>(color ?? Theme.of(context).highlightColor),
                  //backgroundColor: MaterialStateProperty.all<Color>(color ?? Theme.of(context).colo)
                ),

                child: Text(
                  text,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).cardColor ),
                ),
                onPressed: disabled ? null : onPressed as void Function()?))
      ]));
}

Future<T?> showAlertOld<T>(BuildContext context, Widget title, Widget content,
    List<TextButton> actions,
    {GlobalKey? key, dismissible = false}) async {
  return showDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    builder: (BuildContext context) {
      return WillPopScope(
          onWillPop: () async =>
          false, // prevent closing on back button pressed
          child:
          AlertDialog(key: key, title: title, content: content, actions: [
            SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions))
          ]));
    },
  );
}

Future<void> showBusyDialog(BuildContext context, GlobalKey key,
    {String msg = 'Please Wait ....',
      Duration syncWait = const Duration(milliseconds: 200)}) async {
  unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async =>
            false, // prevent closing on back button pressed
            child: SimpleDialog(
                key: key,
                backgroundColor: Colors.transparent,
                children: <Widget>[
                  Center(
                    child: Column(children: [
                      LoadIndicator(),
                      SizedBox(
                        height: 10,
                      ),
                      Text(msg)
                    ]),
                  )
                ]));
      }));
  // Sync
  await Future.delayed(syncWait);
}

Future<void> hideBusyDialog(GlobalKey dialogKey,
    {Duration syncWait = const Duration(milliseconds: 200)}) async {
  if (dialogKey.currentContext != null) {
    Navigator.of(dialogKey.currentContext!, rootNavigator: true).pop();
    // sync
    await Future.delayed(syncWait);
  }
}

Future<DateTime?> pickDate(BuildContext context, DateTime firstDate,
    DateTime initDate, DateTime lastDate) async {
  final locale = Localizations.maybeLocaleOf(context);
  final picked = await showDatePicker(
      context: context,
      firstDate: firstDate,
      initialDate: initDate,
      lastDate: lastDate,
      locale: locale);
  return picked;
}

IconButton settingsButton(BuildContext context,
    {final iconSize = 24.0, Future<void> Function()? onWillPop}) {
  return IconButton(
    icon: Icon(Icons.settings, color: Theme.of(context).primaryColor),
    iconSize: iconSize,
    tooltip: 'Settings',
    onPressed: () async {
      //TODO: not implemented yet
      /*return Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => SettingsScreen(), fullscreenDialog: true),
      ).then((value) => onWillPop != null ? onWillPop() : null);*/
    },
  );
}
