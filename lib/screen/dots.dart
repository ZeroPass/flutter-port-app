import 'package:dots_indicator/dots_indicator.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import 'package:flutter/material.dart';
import 'dart:async';


class Dots extends StatefulWidget {
  int numberOfDots;

  Dots({@required this.numberOfDots});

  @override
  _DotsState createState() => _DotsState();
}

class _DotsState extends State<Dots> {
  double activeDot;
  Timer timer;

  @override
  void initState() {
    super.initState();
    activeDot = 0;
    timer = Timer.periodic(Duration(milliseconds: 666), (Timer t) => update());
  }

  @override
  void dispose() {
    //cancel the timer
    timer.cancel();
    super.dispose();
  }

  void update() {
    setState(() {
      activeDot = (activeDot + 1) % this.widget.numberOfDots;
    });
  }

  @override
  Widget build(BuildContext context) {

    return DotsIndicator(
      dotsCount: this.widget.numberOfDots,
      position: this.activeDot,
      decorator: DotsDecorator(
        spacing: const EdgeInsets.all(5.0),
        color: AndroidThemeST().getValues()
            .themeValues["BUFFER_SCREEN"]["DOT_COLOR_UNACTIVE"], // Inactive color
        activeColor: AndroidThemeST().getValues()
            .themeValues["BUFFER_SCREEN"]["DOT_COLOR_ACTIVE"],
      ),

    );
  }
}