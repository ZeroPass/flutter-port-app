import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:card_settings/card_settings.dart';
import 'package:flutter/foundation.dart';

Widget CustomCardSettingsSection({
        @required List<CardSettingsWidget> children,
        @required String header = null,
        Divider divider = null
})
{
    if (divider == null)
      divider = Divider(indent: 30, endIndent: 30,);

    return CardSettingsSection(
          divider: divider,
          children: children,
          header: header != null ? CardSettingsHeader(label: header) : null
    );

  }
