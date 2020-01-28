import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eosign_mobile_app/screen/main/stepper/stepper.dart';
import 'package:eosign_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final List<Step> steps = [
    Step(
      title: Text("Step 1"),
      //content: StepEnterAccountForm(temp: 2),
      content: BlocProvider<StepEnterAccountBloc>(
                create: (context) => StepEnterAccountBloc(),
                child: StepEnterAccountForm(temp: 1)
      ),
      isActive: true,
    ),
    Step(
      title: Text("Step 2"),
      content: Text("World!"),
      state: StepState.editing,
      isActive: true,
    ),
    Step(
      title: Text("Step 3"),
      content: Text("Hello World!"),
      isActive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    print("application starts");
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('PassID'),
        ),
        body: BlocProvider(
          create: (context) => StepperBloc(maxSteps: steps.length),
          child: StepperForm(steps: steps),
        ),
      ),
    );
  }
}