import 'package:flutter/cupertino.dart';

class CustomSize{
  static double getMaxWidth(BuildContext context, int padding){
    return MediaQuery.of(context).size.width - padding - padding;
  }
}