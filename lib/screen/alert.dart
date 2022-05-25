import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

final _defaultActions = (BuildContext ctx) => [
      PlatformDialogAction(
          child: PlatformText('Close',
              style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () => Navigator.pop(ctx))
    ];


/// Shows platform alert dialog using [context] and [title].
/// The [content] is optional and represents message body.
/// If [actions] list is not provided, the default action list
/// is used e.g. Close button.
///
/// The [dismissible] parameter if set to true will
/// close the alert dialog on Android when user presses outside of alert dialog.
///
/// The [closeOnBackPressed] parameter if set to true will
/// close the alert dialog when user presses back button on android device.
Future<T?> showAlert<T>(
    {required BuildContext context,
    required Widget title,
      Widget? content,
      List<PlatformDialogAction>? actions,
    dismissible = false,
    closeOnBackPressed = false}) async {
      return showPlatformDialog<T>(
        context: context,
        barrierDismissible: dismissible,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async =>
                  closeOnBackPressed, // prevent closing on back button pressed
              child: PlatformAlertDialog(
                  //key: key,
                  title: title,
                  content: content,
                  actions: actions ?? _defaultActions(context)));
        },
  );
}
