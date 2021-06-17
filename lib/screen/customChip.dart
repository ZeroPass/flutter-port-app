import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';

class CustomChip extends StatefulWidget {
  List<String> titles;

  CustomChip({required this.titles});

  @override
  _CustomChipState createState() => _CustomChipState();
}

class _CustomChipState extends State<CustomChip> {
  _CustomChipState();

  @override
  Widget build(BuildContext context) {

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 0.0,

      children: <Widget>[
        for (var item in widget.titles)
          FilterChip(
            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
            labelPadding: EdgeInsets.fromLTRB(0, -3, 0, -3),
            backgroundColor: AndroidThemeST().getValues().themeValues["STEPPER"]["CHIP"]["COLOR_BACKGROUND"],
            selectedColor: AndroidThemeST().getValues().themeValues["STEPPER"]["CHIP"]["COLOR_BACKGROUND"],
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            pressElevation: 0.0,
            label: Text(item, style: TextStyle(color: AndroidThemeST().getValues().themeValues["STEPPER"]["CHIP"]["COLOR_TEXT"],
                        fontSize: AndroidThemeST().getValues().themeValues["STEPPER"]["CHIP"]["SIZE_TEXT"])),
            selected: false,
            onSelected: (bool value) { /*do nothing*/  },
          ),
      ],
    );
  }
}