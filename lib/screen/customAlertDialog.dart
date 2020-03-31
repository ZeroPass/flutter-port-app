import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:bloc/bloc.dart';

class CustomAlertDialog {
  BuildContext context;
  String error;
  Function callbackOnPressed;

  CustomAlertDialog([@required BuildContext this.context, @required String this.error, Function this.callbackOnPressed = null]);

  void show(BuildContext context){
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text('Cannot continue'),
        content: Text(error + '\nPlease fill the form with valid data.'),
        actions: <Widget>[
          PlatformDialogAction(
              child: PlatformText('OK', style: TextStyle(color: AndroidThemeST().getValues().themeValues["STEPPER"]["STEPPER_MANIPULATOR"]["COLOR_TEXT"])),
              onPressed: () {
                if (this.callbackOnPressed != null)
                  callbackOnPressed();
                Navigator.pop(context);
              }
          )
        ],
      ),
    );
  }
}
