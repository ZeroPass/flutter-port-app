import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import "dart:io" show Platform;


class CustomButton extends StatefulWidget {
  String title;
  double minWidth;
  Function callbackOnPressed;

  CustomButton([@required this.title, @required this.callbackOnPressed, this.minWidth = -1]);

  @override
  _CustomButton createState() => _CustomButton();

}

class _CustomButton extends State<CustomButton> {
  _CustomButton();

  Widget showAndroidButton(BuildContext context){
    return Container(
          child: FlatButton(
            color: AndroidThemeST().getValues().themeValues["BUTTON"]["COLOR_BACKGROUND"],
            textColor: AndroidThemeST().getValues().themeValues["BUTTON"]["COLOR"],
            onPressed: () {
              widget.callbackOnPressed();
            },
            child: Text(
              widget.title,
              style: TextStyle(fontSize: AndroidThemeST().getValues().themeValues["BUTTON"]["SIZE_TEXT"]),
            ),
          )
      );
  }


  Widget showIosButton(BuildContext context){
    return  Container(
        child:  CupertinoButton (
          onPressed: ()=>{widget.callbackOnPressed()},
          color: AndroidThemeST().getValues().themeValues["BUTTON"]["COLOR_BACKGROUND"],
          borderRadius: new BorderRadius.circular(30.0),
          padding: EdgeInsets.only(right: 60.0, left: 60.0),
          child:
          new Text(widget.title,
            textAlign: TextAlign.center,
            style: new TextStyle(color: AndroidThemeST().getValues().themeValues["BUTTON"]["COLOR"]),
          ),
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid)
    {
      return this.showAndroidButton(context);
    }
    else if (Platform.isIOS)
    {
      return this.showIosButton(context);
    }
    else
      return null;
  }
}