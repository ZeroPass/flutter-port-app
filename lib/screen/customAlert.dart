import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

Future<T> showAlert<T>(BuildContext context, Widget title, Widget content,
    List<FlatButton> actions,
    {GlobalKey key, dismissible = false}) async {
  return showDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    builder: (BuildContext context) {
      return WillPopScope(
          onWillPop: () async =>
          false, // prevent closing on back button pressed
          child: AlertDialog(
              key: key, title: title, content: content, actions: actions));
    },
  );
}