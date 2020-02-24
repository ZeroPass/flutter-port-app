import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:eosign_mobile_app/screen/main/stepper/stepper.dart";
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosign_mobile_app/utils/storage.dart';

class StepperForm extends StatefulWidget {
  final List<Step> steps;

  StepperForm({Key key, @required this.steps}) : super(key: key);

  @override
  _StepperFormState createState() => _StepperFormState(steps: steps);
}

class _StepperFormState extends State<StepperForm> {
  //Stepper steps
  final List<Step> steps;

  _StepperFormState({Key key, @required this.steps});

  @override
  Widget build(BuildContext context) {
    final stepperBloc = BlocProvider.of<StepperBloc>(context);
    return BlocBuilder(
      bloc: stepperBloc,
      builder: (BuildContext context, StepperState state) {
        print(MaterialLocalizations.of(context));
        return Stepper(
                currentStep: state.step,
                steps: steps,
                type: StepperType.vertical,
                onStepTapped: (step) {
                  stepperBloc.modifyHeader(state.step, step, context);
                  stepperBloc.add(StepTapped(step: step));
                },
                onStepCancel: () {
                  stepperBloc.add(StepCancelled());
                },
                onStepContinue: () {
                  stepperBloc.modifyHeader(state.step, state.step + 1, context);
                  stepperBloc.add(StepContinue());
                },
                controlsBuilder: (BuildContext context,
                    {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                  return Row(
                    //mainAxisSize: MainAxisSize.max,
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      PlatformButton (

                        onPressed: () {
                          Storage s = Storage();
                          //is button 'next' unlocked
                          if (s.getStorageData(state.step).isUnlocked){
                            //stepperBloc.
                            onStepContinue();
                          }
                          else {
                            showPlatformDialog(
                              context: context,
                              builder: (_) => PlatformAlertDialog(
                                title: Text('Cannot continue'),
                                content: Text('Please fill the form with valid data'),
                                actions: <Widget>[
                                  PlatformDialogAction(
                                    child: PlatformText('OK'),
                                    onPressed: () => Navigator.pop(context)
                                  )
                                ],
                              ),
                            );
                          }
                        },
                        child:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text('Continue',style: TextStyle(color: Colors.white)),
                  ]
                  )

                      )
                    ],
                  );
                }
        );
      },
    );
  }
}
