import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:port_mobile_app/screen/flow/stepInputData/stepInputData.dart';

class FlowApp extends StatefulWidget {
  @override
  _FlowApp createState() => _FlowApp();
}

class _FlowApp extends State<FlowApp> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(child: StepInputData());
  }
}