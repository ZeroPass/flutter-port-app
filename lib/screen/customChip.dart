import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import 'package:bloc/bloc.dart';

class CustomChip extends StatefulWidget {
  List<String> titles;

  CustomChip([@required this.titles]);

  @override
  _CustomChipState createState() => _CustomChipState();
}

class _CustomChipState extends State<CustomChip> {
  _CustomChipState();

  @override
  Widget build(BuildContext context) {

    return Transform(
        alignment: Alignment.center,
        transform: new Matrix4.identity()..scale(0.8),
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: 3.0,

      children: <Widget>[
        for (var item in widget.titles)
        FilterChip(
          backgroundColor: AndroidThemeST().getValues().themeValues["STEPPER"]["CHIP"]["COLOR_BACKGROUND"],
          selectedColor: AndroidThemeST().getValues().themeValues["STEPPER"]["CHIP"]["COLOR_BACKGROUND"],

          pressElevation: 0.0,
          label: Text(item, style: TextStyle(color: AndroidThemeST().getValues().themeValues["STEPPER"]["CHIP"]["COLOR_TEXT"],
                      fontSize: AndroidThemeST().getValues().themeValues["STEPPER"]["CHIP"]["SIZE_TEXT"])),
          selected: false,
        ),
      ],
    )
    );
  }
}