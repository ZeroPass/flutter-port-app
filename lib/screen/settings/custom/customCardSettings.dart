import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:card_settings/card_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:card_settings/interfaces/minimum_field_properties.dart';


class CustomCardSettings extends StatefulWidget implements IMinimumFieldSettings {
  @override
  final bool showMaterialonIOS;
  bool visible;
  final List<CardSettingsSection> children;

  CustomCardSettings({
    required this.children,
    this.visible = true,
    this.showMaterialonIOS = true //not yet in use
  });

  @override
  _CustomCardSettings createState() => _CustomCardSettings();
}

class _CustomCardSettings extends State<CustomCardSettings> {

  _CustomCardSettings();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CardSettings(
          children: widget.children,
          margin: EdgeInsets.all(0.0)
      ),
    );

  }
}
