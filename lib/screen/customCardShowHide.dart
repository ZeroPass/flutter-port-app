import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';

class CustomCardShowHide extends StatefulWidget {
  late String title;
  late String item;
  late final List<Widget> actions;

  CustomCardShowHide(this.title, this.item,
      {required this.actions});

  @override
  _CustomCardShowHideState createState() => _CustomCardShowHideState();
}

class _CustomCardShowHideState extends State<CustomCardShowHide> {
  late bool _visability;

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
                          color: Platform.isIOS //make it blue always
                            ? CupertinoColors.systemBlue
                            : AndroidThemeST()
                              .getValues()
                              .themeValues["CUSTOM_CARD"]["COLOR_TEXT_OPEN_CLOSE"]),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 14.0, right: 14.0, top: 14.0, bottom: 0.0),
                                child: SelectableText(

                                  this.widget.item,
                                  scrollPhysics: BouncingScrollPhysics(),
                                  style: TextStyle(fontSize: 15),
                                  maxLines: 15,
                                  minLines: 2,
                                )),
                            if (widget.actions != null)
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.end,
                                  alignment: WrapAlignment.end,
                                  direction: Axis.horizontal,
                                  runSpacing: 1,
                                  spacing: 1,
                                  children: <Widget>[...widget.actions])
                              )
                          ],
              ))))
            : new Container(), //element is not visable; 'show' only containter
      ],
    );
  }
}
