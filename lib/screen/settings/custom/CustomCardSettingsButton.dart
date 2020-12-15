import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:card_settings/card_settings.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:flutter/foundation.dart';
import 'package:card_settings/interfaces/minimum_field_properties.dart';


class CustomCardSettingsButton extends StatefulWidget implements IMinimumFieldSettings {
  @override
  final bool showMaterialonIOS;
  String label;
  bool enabled;
  bool visible;
  double bottomSpacing;
  Function onPressed;

  CustomCardSettingsButton({
    @required this.label,
    this.enabled = true,
    this.visible = true,
    this.bottomSpacing = 5.0,
    @required this.onPressed,
    this.showMaterialonIOS = true //not yet in use
  }){}

  @override
  _CustomCardSettingsButton createState() => _CustomCardSettingsButton();
}

class _CustomCardSettingsButton extends State<CustomCardSettingsButton> {

  _CustomCardSettingsButton();

  @override
  Widget build(BuildContext context) {
    return Container(
        child: CardSettingsButton(
                                label: widget.label,
                                enabled: widget.enabled,
                                visible: widget.visible,
                                bottomSpacing: widget.bottomSpacing,
                                onPressed: widget.onPressed,
                                textColor: Color(0xFFa58157),
                                backgroundColor: Color(0x00FFFFFF) //unvisible white color,
                                ),

    );

  }
}
