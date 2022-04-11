import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:eosio_port_mobile_app/utils/color.dart';
//import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart'; //temptemp
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
    "STEP_HEADER":
    {
      "COLOR_CIRCLE" : Color(0xFFa58157),
      "COLOR_CIRCLE_DISABLED": Colors.black12
    },
    "CHIP":
    {
      "SIZE_TEXT":14.0,
      "COLOR_TEXT":Color(0xFFa55900),
      "COLOR_BACKGROUND":Color(0xFFEEEEEE)
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
    "COMPANY_NAME": "ZeroPass"
  },
  "FLUSHBAR":
  {
    "COLOR_TEXT":  Colors.white,
    "COLOR_BACKGROUND":Color(0xFFa58157)
  },
  "CUSTOM_CARD":
  {
    "SIZE_TEXT":17.0,
    "COLOR_TEXT":Color(0xFF646464),
    "COLOR_TEXT_OPEN_CLOSE":Color(0xff5768a5)
  },
  "BUFFER_SCREEN":
  {
    "DURATION_MILISECONDS": 1000,
    "DOT_COLOR_UNACTIVE": Color(0xFFF1F1F1),
    "DOT_COLOR_ACTIVE" : Color(0xFFa58157)
  },
  "QR_SCREEN":
  {
    "COLOR_FOCUS_BORDER": Color(0xFFa58157)
  },
  "INDEX_SCREEN":
  {
    "COLOR_BACKGROUND": Color(0xFFa58157)
  },
  "OUTSIDE_CALL":
  {
    "BAR_BACKGROUND_COLOR": Color(0xFFa58157),
    "BAR_TEXT_COLOR": Colors.white
  },
};
//the same valus for now
ThemeValues DARK_VALUES= ThemeValues(themeValues: light);
ThemeValues LIGHT_VALUES = ThemeValues(themeValues: light);



class ThemeValues{
  ThemeValues({required Map themeValues})
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
      "STEP_HEADER":
      {
      "COLOR_CIRCLE" : null,
      "COLOR_CIRCLE_DISABLED": null
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
      "COMPANY_NAME": "ZeroPass"
    },
    "FLUSHBAR":
    {
      "COLOR_TEXT": null,
      "COLOR_BACKGROUND": null
    },
    "CUSTOM_CARD":
    {
      "SIZE_TEXT": null,
      "COLOR_TEXT": null,
      "COLOR_TEXT_OPEN_CLOSE": null
    },
    "BUFFER_SCREEN":
    {
      "DURATION_MILISECONDS": null,
      "DOT_COLOR_UNACTIVE": null,
      "DOT_COLOR_ACTIVE" : null
    },
    "QR_SCREEN":
    {
      "COLOR_FOCUS_BORDER": null
    },
    "INDEX_SCREEN":
    {
      "COLOR_BACKGROUND": null
    },
    "OUTSIDE_CALL":
    {
      "BAR_BACKGROUND_COLOR": null,
      "BAR_TEXT_COLOR": null
    },

  };

  get themeValues => _themeValues;

  set themeValues(value) {
    _themeValues = value;
  }
}

//change the color of navigation color
void changeNavigationBarColor() async {
  try {
    SystemChrome.setEnabledSystemUIMode (SystemUiMode.manual, overlays: SystemUiOverlay.values);
    //FlutterStatusbarcolor.setStatusBarColor(Color(0xFF4f5f96));
    //await FlutterStatusbarcolor.setNavigationBarColor(Color(0xFFF0F0F0));
    //FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);temptemp
  } on PlatformException catch (e) {
    debugPrint(e.toString());
  }
}

void removeNavigationBar() async {
  try {
    //SystemChrome.setEnabledSystemUIOverlays ([SystemUiOverlay.top]);
    SystemChrome.setEnabledSystemUIMode (SystemUiMode.manual, overlays: []);
  } on PlatformException catch (e) {
    debugPrint(e.toString());
  }
}

void showNavigationBar() async {
  try {
    //SystemChrome.setEnabledSystemUIMode (SystemUiOverlay.values);
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
        ),
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
    barBackgroundColor: Color.fromARGB(255, 87, 104, 165),
    textTheme: CupertinoTextThemeData(
      primaryColor: CupertinoColors.white,
      navTitleTextStyle: TextStyle(
        inherit: false, // TODO: this should be true, but there is an error when transiting between routes
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.normal
      ),
      navActionTextStyle: TextStyle(
        inherit: false, // TODO: this should be true, but there is an error when transiting between routes
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.normal
      ),
      navLargeTitleTextStyle: TextStyle(
        inherit: false, // TODO: this should be true, but there is an error when transiting between routes
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.normal
      ))
  );
}
