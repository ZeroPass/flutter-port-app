import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:eosign_mobile_app/utils/color.dart';

/*
class ThemeForm extends StatefulWidget {
  //final List<Step> steps;

  ThemeForm({Key key}) : super(key: key);

  @override
  _ThemeFormState createState() => _ThemeFormState();
}

class _ThemeFormState extends State<ThemeForm> {

  _ThemeFormState({Key key});

  @override
  Widget build(BuildContext context) {
    return MaterialAppData(theme: ThemeData(primarySwatch: Colors.purle));
  }
}*/

abstract class Theme{
  ThemeData getLight();
  ThemeData getDark();
}

class AndroidTheme extends Theme{
  ThemeData getLight() {
    MaterialColor _primaryColor = CustomColor.createColor(83, 37, 153, 0xFF5768a5);
    return ThemeData(primarySwatch: _primaryColor,
        buttonColor: Color(0xFFa58157)
    );
  }

  ThemeData getDark(){
    var _primaryColor = CustomColor.createColor(83, 37, 153, 0xFF532599);
    return ThemeData(primarySwatch: _primaryColor,
        buttonColor: Color(0xFF7c3bcc)
    );
  }
}

class IOSTheme extends Theme{
  ThemeData getLight() {

  }

  ThemeData getDark(){

  }
}