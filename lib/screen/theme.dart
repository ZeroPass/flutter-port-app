import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:eosio_passid_mobile_app/utils/color.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter/services.dart';

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
      "SIZE_TEXT":14.0,
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
      "SIZE_SMALLER_TEXT":15.0,
      "COLOR_TEXT":Color(0xFF646464)
    },
    "STEP_TAP":
    {
      "SIZE_TEXT":17.0,
      "COLOR_TEXT":Color(0xFF646464)
    },
    "STEP_REVIEW":
    {
      "SIZE_TEXT":17.0,
      "COLOR_TEXT":Color(0xFF646464)
    }
  },
  "BUTTON":
  {
    "COLOR": Colors.white,
    "COLOR_BACKGROUND":Color(0xFFa58157),
    "SIZE_TEXT": 17.0
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
  },
  "FLUSHBAR":
  {
    "COLOR_TEXT":  Colors.white,
    "COLOR_BACKGROUND":Color(0xFFa58157)
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
        "SIZE_SMALLER_TEXT":null,
        "COLOR_TEXT":null
      },
      "STEP_TAP":
      {
        "SIZE_TEXT":null,
        "COLOR_TEXT":null
      },
      "STEP_REVIEW":
      {
        "SIZE_TEXT":null,
        "COLOR_TEXT":null
      }
    },
    "BUTTON":
    {
      "COLOR": null,
      "COLOR_BACKGROUND":null,
      "SIZE_TEXT": null
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
    "FLUSHBAR":
    {
      "COLOR_TEXT": null,
      "COLOR_BACKGROUND": null
    }
  };

  get themeValues => _themeValues;

  set themeValues(value) {
    _themeValues = value;
  }
}

//change the color of navigation color
void changeNavigationBarColor() async {
  try {
    SystemChrome.setEnabledSystemUIOverlays (SystemUiOverlay.values);
    FlutterStatusbarcolor.setStatusBarColor(Color(0xFF4f5f96));
    await FlutterStatusbarcolor.setNavigationBarColor(Color(0xFFF0F0F0));
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
  } on PlatformException catch (e) {
    debugPrint(e.toString());
  }
}

void removeNavigationBar() async {
  try {
    //SystemChrome.setEnabledSystemUIOverlays ([SystemUiOverlay.top]);
    SystemChrome.setEnabledSystemUIOverlays ([]);
  } on PlatformException catch (e) {
    debugPrint(e.toString());
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
    MaterialColor _primaryColor = CustomColor.createColor(165, 129, 87, 0xFF5768a5);
    return ThemeData(primarySwatch: _primaryColor,
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFFa58157),
          textTheme: ButtonTextTheme.primary,
        )
    );
  }

  ThemeData getDark(){
    this.selectedTheme = 0;
    var _primaryColor = CustomColor.createColor(83, 37, 153, 0xFF532599);
    return ThemeData(primarySwatch: _primaryColor,
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFFa58157),
          textTheme: ButtonTextTheme.normal,
        )
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


CupertinoThemeData iosThemeData() {
  return CupertinoThemeData(
    brightness: Brightness.light, // force light theme as way around for buggy dark theme. 
    barBackgroundColor: Color.fromARGB(255, 87, 104, 165)
  );
}
