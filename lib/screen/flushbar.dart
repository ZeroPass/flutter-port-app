import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';

BuildContext STATIC_BUILD_CONTEXT = null;

void setGlobalStaticBuildContext(BuildContext context)
{
  STATIC_BUILD_CONTEXT = context;
}

void showFlushbar(String title, String message, {int duration = 5})
{
  if (STATIC_BUILD_CONTEXT == null)
    throw Exception("Global variable 'STATIC_BUILD_CONTEXT' is not set");

  Flushbar(
    title:  title,
    message:  message,
    duration:  Duration(seconds: duration),
  )..show(STATIC_BUILD_CONTEXT);
}