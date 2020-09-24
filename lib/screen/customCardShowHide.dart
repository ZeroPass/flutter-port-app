import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';

class CustomCardShowHide extends StatefulWidget {
  String title;
  String item;
  final List<Widget> actions;

  CustomCardShowHide(@required this.title, @required this.item,
      {this.actions = null});

  @override
  _CustomCardShowHideState createState() => _CustomCardShowHideState();
}

class _CustomCardShowHideState extends State<CustomCardShowHide> {
  bool _visability;

  _CustomCardShowHideState() {
    _visability = false;
  }

  void _changeVisability() {
    setState(() {
      _visability = _visability ? false : true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 0.0,
      children: <Widget>[
        InkWell(
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              this._changeVisability();
            },
            child: Container(
                padding: EdgeInsets.only(
                    top: 3.0, bottom: 3.0, left: 14.0, right: 14.0),
                //make bigger touch area
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.title,
                      style: TextStyle(
                          color: Platform.isIOS 
                            ? CupertinoColors.activeBlue
                            : AndroidThemeST()
                                .getValues()
                                .themeValues["CUSTOM_CARD"]["COLOR_TEXT"]),
                    )))),
        _visability
            ? SizedBox(
                width: double.infinity,
                child: Card(
                    //element is visable
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0))),
                    elevation: 0.0, //no shadow
                    margin: EdgeInsets.symmetric(horizontal: 0.0),
                    child: Padding(
                        padding: EdgeInsets.all(0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 14.0, right: 14.0, top: 5.0),
                                child: SelectableText(
                                  this.widget.item,
                                  style: TextStyle(fontSize: 15),
                                )),
                            if (widget.actions != null)
                              Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.end,
                                  alignment: WrapAlignment.end,
                                  direction: Axis.horizontal,
                                  runSpacing: 1,
                                  spacing: 1,
                                  children: <Widget>[...widget.actions])
                          ],
                        ))))
            /*const SizedBox(height: 30),

          */
            : new Container(), //element is not visable; 'show' only containter
      ],
    );
  }
}
