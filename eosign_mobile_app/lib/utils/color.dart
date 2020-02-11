import 'package:flutter/material.dart';

class CustomColor{
  //create custom color (hex value should be with alpha channel - starts with 0xFF
  static MaterialColor createColor(int r, int g, int b, int hex){
    Map<int, Color> color ={50:Color.fromRGBO(r, g, b, .1),
      100:Color.fromRGBO(r, g, b, .2),
      200:Color.fromRGBO(r, g, b, .3),
      300:Color.fromRGBO(r, g, b, .4),
      400:Color.fromRGBO(r, g, b, .5),
      500:Color.fromRGBO(r, g, b, .6),
      600:Color.fromRGBO(r, g, b, .7),
      700:Color.fromRGBO(r, g, b, .8),
      800:Color.fromRGBO(r, g, b, .9),
      900:Color.fromRGBO(r, g, b, 1),};

    return MaterialColor(hex, color);
  }
}