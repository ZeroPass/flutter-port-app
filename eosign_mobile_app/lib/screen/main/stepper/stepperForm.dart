import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:eosign_mobile_app/screen/main/stepper/stepper.dart";
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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

  /*Widget buttonContinue() {
    return new RaisedButton(
      child: new Text(
          _isButtonDisabled ? "Hold on..." : "Increment"
      ),
      onPressed: _isButtonDisabled ? null : _incrementCounter,
    );
  }*/

  @override
  Widget build(BuildContext context) {
    print("Stepper form state");
    bool _isButtonNextEnabled = true;

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
                  stepperBloc.add(StepTapped(step: step));
                },
                onStepCancel: () {
                  stepperBloc.add(StepCancelled());
                },
                onStepContinue: () {
                  stepperBloc.add(StepContinue());
                },
                controlsBuilder: (BuildContext context,
                    {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                  return Row(
                    //mainAxisSize: MainAxisSize.max,
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      PlatformButton (
                        onPressed: onStepContinue,
                        child: const Text('Continue'),
                      )
                    ],
                  );

                  FlatButton(
                    //onPressed: onStepContinue,
                    child: Text("Flat Button"),
                    color: Color.fromRGBO(0, 0, 100, 1.0),
                    onPressed: () {
                      print(_isButtonNextEnabled);
                      if (_isButtonNextEnabled)
                        _isButtonNextEnabled = false;
                      else
                        _isButtonNextEnabled = true;
                      //setState(() => _isButtonNextEnabled = false);
                    },
                  );
                  /*return ProgressButtonWidget(
                  backgroundColor: Colors.lightBlueAccent,
                  buttonTitle: "Continoue",
                  onpress
                );*/
                }

              /*controlsBuilder: (BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
              return FlatButton(
                    //onPressed: onStepContinue,
                    child: SvgPicture.asset('assets/svg/doubleDown/doubleDownIcon.svg', width: 20, height: 20, color: Color.fromRGBO(0, 0, 0, 0.2)),
                    onPressed: () {
                      print (_isButtonNextEnabled);
                      if (_isButtonNextEnabled) _isButtonNextEnabled = false;
                      else _isButtonNextEnabled = true;
                      //setState(() => _isButtonNextEnabled = false);
                  },
              );
            }*/
              /*Column(
                children: <Widget>[
                  SizedBox(height: AppSize.smallMedium,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ProgressButtonWidget(
                        backgroundColor: Colors.lightBlueAccent,
                        buttonTitle: Constants.continueButton,
                        tapCallback: (){
                          setState(() {
                            // update the variable handling the current step value
                            // going back one step i.e adding 1, until its the length of the step
                            if (currentStep < mySteps.length - 1) {
                              currentStep = currentStep + 1;
                            } else {
                              state.step = 0;
                            }
                          });
                        },
                      ),
                      SizedBox(width: AppSize.small,),
                      ProgressButtonWidget(
                        backgroundColor: Colors.grey,
                        buttonTitle: Constants.cancelButton,
                        tapCallback: (){
                          // On hitting cancel button, change the state
                          setState(() {
                            // update the variable handling the current step value
                            // going back one step i.e subtracting 1, until its 0
                            if (currentStep > 0) {
                              currentStep = currentStep - 1;
                            } else {
                              currentStep = 0;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: AppSize.smallMedium,),
                ],
              );*/

        );
      },
    );
  }
}
