import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eosio_port_mobile_app/screen/theme.dart';
import "dart:io" show Platform;


class CustomButton extends StatefulWidget {
  late String title;
  late double minWidth;
  late Color fontColor;
  late Color backgroundColor;
  late double fontSize;
  late Function callbackOnPressed;
  late bool disabled;

  CustomButton({required this.title, required this.callbackOnPressed, Color? fontColor,
    this.backgroundColor = Colors.white, double? fontSize, this.minWidth = 44.0, this.disabled = false})
  {
      this.fontColor = fontColor ?? AndroidThemeST().getValues().themeValues["BUTTON"]["COLOR"];
      this.fontSize =  fontSize ?? AndroidThemeST().getValues().themeValues["BUTTON"]["SIZE_TEXT"];
  }

  @override
  _CustomButton createState() => _CustomButton();

}

class _CustomButton extends State<CustomButton> {
  _CustomButton();

  Widget showAndroidButton(BuildContext context){
    return Container(
          child: FlatButton(
            color: widget.backgroundColor,
            textColor:widget.fontColor,
            onPressed: () {
              if (widget.disabled == false)
                widget.callbackOnPressed();
            },
            child: Text(
              widget.title,
              style: TextStyle(fontSize:widget.fontSize),
            ),
          )
      );
  }


  Widget showIosButton(BuildContext context){
    print(widget.minWidth);
    return  Container(
        child:  CupertinoButton (
          onPressed: ()=>{widget.callbackOnPressed()},
          color: widget.backgroundColor,
          borderRadius: new BorderRadius.circular(30.0),
          padding: EdgeInsets.only(right: 60.0, left: 60.0),
          child:
          new Text(widget.title,
            textAlign: TextAlign.center,
            style: new TextStyle(color: widget.fontColor),
          ),
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid)
    {
      return this.showIosButton(context);
      //return this.showAndroidButton(context);
    }
    else if (Platform.isIOS)
    {
      return this.showIosButton(context);
    }
    else
      throw Exception("CustomButton.build: unknown platform.");
  }
}