import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';


class CustomCardSettingsButtonDelete extends StatefulWidget{
  late Function() onPressed;

  CustomCardSettingsButtonDelete({
    required this.onPressed
    });

  @override
  _CustomCardSettingsButtonDelete createState() => _CustomCardSettingsButtonDelete();
}

class _CustomCardSettingsButtonDelete extends State<CustomCardSettingsButtonDelete> {

  _CustomCardSettingsButtonDelete();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 20),
      child: FlatButton(
          color: Colors.red,
          textColor: Colors.white,
          child: const Text('DELETE', style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: widget.onPressed)
    );
  }
}
