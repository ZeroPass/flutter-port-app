import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_passid_mobile_app/screen/customButton.dart';
import 'package:bloc/bloc.dart';

class CustomAlertDialog {
  BuildContext context;
  String title;
  String content;
  Function callbackOnPressed;

  CustomAlertDialog([@required BuildContext this.context, @required String this.title, @required String this.content, Function this.callbackOnPressed = null])
  {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(this.title),
        content: Text(this.content),
        actions: <Widget>[
          PlatformDialogAction(
              child: Center(child:
              CustomButton(title:"ok",
                  backgroundColor: Colors.white,
                  fontColor: Colors.blue,
                  callbackOnPressed: (){
                callbackOnPressed();
                Navigator.pop(context);
              }))
          )
        ],
      )
    );
  }
}
