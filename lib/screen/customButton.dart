import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import "dart:io" show Platform;


class CustomButton extends StatefulWidget {
  String title;
  double minWidth;
  Color fontColor;
  Color backgroundColor;
  double fontSize;
  Function callbackOnPressed;

  CustomButton({@required this.title, @required this.callbackOnPressed, this.fontColor = null, this.backgroundColor = Colors.white, this.fontSize = null, this.minWidth = null})
  {
    if (this.fontColor == null)
      this.fontSize =  AndroidThemeST().getValues().themeValues["BUTTON"]["COLOR"];

    if (this.fontSize == null)
      this.fontSize =  AndroidThemeST().getValues().themeValues["BUTTON"]["SIZE_TEXT"];

    if(this.minWidth == null)
      this.minWidth = 44.0;

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
      return null;
  }
}