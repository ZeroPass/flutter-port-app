import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:eosio_passid_mobile_app/utils/color.dart';

/*
 Make sure to fill all values
*/
Map light = {
  "STEPPER":
  {
    "BUTTON_NEXT":
    {
      "COLOR_BACKGROUND": Color(0xFFa58157),
      "COLOR_TEXT": Colors.white
    },
    "BUTTON_DELETE":
    {
      "COLOR_BACKGROUND": Color(0xFFa58157),
    },
    "CHIP":
    {
      "SIZE_TEXT":17.0,
      "COLOR_TEXT":Color(0xFFa55900),
      "COLOR_BACKGROUND":Color(0xFFfce4c7)
    },
    "STEPPER_MANIPULATOR":
    {
      "SIZE_TEXT":17.0,
      "COLOR_TEXT":Color(0xFFa58157)
    },
    "STEP_SCAN":
    {
      "SIZE_TEXT":17.0,
      "COLOR_TEXT":Color(0xFF646464)
    },
    "STEP_TAP":
    {
      "SIZE_TEXT":17.0,
      "COLOR_TEXT":Color(0xFF646464)
    }
  },
  "TILE_BAR":
  {
    "SIZE_TEXT": 17.0,
    "COLOR_TEXT":  Color(0xFFa58157),
    "COLOR_BACKGROUND":Color(0xFFa58157)
  },
  "APP_DATA":
  {
    "VERSION": "0.0.1",
    "YEAR_LAST_UPDATE": 2020,
    "COMPANY_NAME": "ZeroPass"
  }
};
//the same valus for now
ThemeValues DARK_VALUES= ThemeValues(themeValues: light);
ThemeValues LIGHT_VALUES = ThemeValues(themeValues: light);



class ThemeValues{
  ThemeValues({@required Map themeValues})
  {
    this._themeValues = themeValues;
  }

  Map _themeValues=
  {
    "STEPPER":
    {
      "BUTTON_NEXT":
      {
        "COLOR_BACKGROUND": null,
        "COLOR_TEX": null
      },
      "BUTTON_DELETE":
      {
        "COLOR_BACKGROUND": null,
      },
      "CHIP":
      {
        "SIZE_TEXT":null,
        "COLOR_TEXT":null,
        "COLOR_BACKGROUND":null
      },
      "STEPPER_MANIPULATOR":
      {
        "SIZE_TEXT":null,
        "COLOR_TEXT":null
      },
      "STEP_SCAN":
      {
        "SIZE_TEXT":null,
        "COLOR_TEXT":null
      },
      "STEP_TAP":
      {
        "SIZE_TEXT":null,
        "COLOR_TEXT":null
      }
    },
    "TILE_BAR":
    {
      "SIZE_TEXT": null,
      "COLOR_TEXT": null,
      "COLOR_BACKGROUND":null
    },
    "APP_DATA":
    {
      "VERSION": "0.0.1",
      "YEAR_LAST_UPDATE": 2020,
      "COMPANY_NAME": "ZeroPass"
    },
  };

  get themeValues => _themeValues;

  set themeValues(value) {
    _themeValues = value;
  }
}

abstract class CustomTheme{
  //0 = black theme, 1 = light theme
  int selectedTheme;

  //fil the values of theme od the top of this file
  ThemeValues lightTheme = LIGHT_VALUES;
  ThemeValues darkTheme = DARK_VALUES;

  ThemeValues getValues()
  {
    return (this.selectedTheme == 1? this.lightTheme: this.darkTheme);
  }

  CustomTheme({this.selectedTheme = 1});
  ThemeData getLight();
  ThemeData getDark();
}

class AndroidTheme extends CustomTheme{

  AndroidTheme(){
    this.selectedTheme = 1;//default theme is light
  }

  ThemeData getLight() {
    this.selectedTheme = 1;
    //CustomColor.createColor(165, 129, 87, 0xFFa58157);
    //MaterialColor _primaryColor = CustomColor.createColor(83, 37, 153, 0xFF5768a5);
    //MaterialColor _primaryColor = CustomColor.createColor(87, 104, 165, 0xFF5768a5);
    MaterialColor _primaryColor = CustomColor.createColor(165, 129, 87, 0xFF5768a5);
    return ThemeData(primarySwatch: _primaryColor,
        buttonColor: Color(0xFFa58157),
      /*chipTheme: ChipThemeData(
        backgroundColor: Color(0xFFa58157),
          selectedColor: Color(0xFFa58157),
          secondarySelectedColor: Color(0xFFa58157),
          //labelPadding,
          //padding,
          //shape,
          //labelStyle,
          //secondaryLabelStyle,
          //brightness,

      )*/
    );
  }

  ThemeData getDark(){
    this.selectedTheme = 0;
    var _primaryColor = CustomColor.createColor(83, 37, 153, 0xFF532599);
    return ThemeData(primarySwatch: _primaryColor,
        buttonColor: Color(0xFFa58157)
    );
  }
}

//singelton class of android theme
class AndroidThemeST extends AndroidTheme {
  static final AndroidThemeST _singleton = new AndroidThemeST._internal();

  factory AndroidThemeST(){
    AndroidTheme();
    return _singleton;
  }

  AndroidThemeST._internal(){
    //initialization your logic here
  }
}


class IOSTheme extends CustomTheme{
  ThemeData getLight() {

  }

  ThemeData getDark(){

  }
}