import 'dart:io';

import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestationHeader/stepAttestationHeader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart";
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScanHeader/stepScanHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepReview/stepReviewHeader/stepReviewHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepReview/stepReview.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import "package:eosio_passid_mobile_app/screen/main/stepper/customStepper.dart";

import '../../alert.dart';

List<String> BUTTON_NEXT_TITLE = ["Continue", "Scan Passport", "Scan Passport", ""];

Widget getButtonNextTitle({@required int stepIndex}){
  if (stepIndex > BUTTON_NEXT_TITLE.length-1)
    throw FormatException("step index is larger than number of all steps");
  return Text(BUTTON_NEXT_TITLE.elementAt(stepIndex));
}

class StepperForm extends StatefulWidget {
  bool isMagnetLink;

  StepperForm({isMagnetLink = null})
  {
    this.isMagnetLink = isMagnetLink == null || isMagnetLink == false ? false : true;
  }

  @override
  _StepperFormState createState() => _StepperFormState();
}

class _StepperFormState extends State<StepperForm> {
  int currentState = 0;
  List<StepState> listState = [
    StepState.indexed,
    StepState.editing,
  ];

  StepState _getState(int step) {
    if (currentState == step)
      return StepState.editing;
    else
      return StepState.indexed;
  }


  //Stepper steps
  List<Step> getSteps(BuildContext context) {
    return <Step>[
      Step(
          title: StepEnterAccountHeaderForm(),
          content: StepEnterAccountForm(),
          state: _getState(0),

      ),
      Step(
          title: StepScanHeaderForm(),
          content: StepScanForm(),
          state: _getState(1),
      ),
      Step(
        title: StepAttestationHeaderForm(),
        content: StepAttestationForm(),
        state: _getState(2),
      ),
      Step(
        title: StepReviewHeaderForm(),
        content: StepReviewForm(),
        state: _getState(3),
      )
    ];
  }

  List<Step> getStepsMagnetLink(BuildContext context) {
    return <Step>[
      Step(
        title: StepEnterAccountHeaderForm(),
        content: StepEnterAccountForm(),
        state: _getState(0),
      ),
      Step(
        title: StepScanHeaderForm(),
        content: StepScanForm(),
        state: _getState(1),
      ),
      Step(
        title: Text("Attestation"),
        content: StepAttestationForm(),
        state: _getState(2),
      )/*,
      Step(
        title: Text("test"),
        content: Text("test1"),
        state: _getState(3),
      )*/
    ];
  }

  _StepperFormState({Key key});



  String onButtonNextPressed(int currentStep) {
    var storage = Storage();
    switch (currentStep) {
      case 0:
        {
          //step 1(Account Name)
          StepDataEnterAccount storageStepEnterAccount =
              storage.getStorageData(0);
          if (storage.selectedNode.name == "ZeroPass Server") return "";
          if (storageStepEnterAccount.isUnlocked == false)
            return "Account is not valid.";
          return "";
        }
        break;

      case 1:
        {
          //step 2(Scan)
          StepDataScan storageStepScan = storage.getStorageData(1);
          String errorMessage = "";
          if (storageStepScan.documentID == null ||
              storageStepScan.documentID == "")
            errorMessage += "Passport No. is not valid.\n";
          if (storageStepScan.birth == null)
            errorMessage += "Date of Birth is empty.\n";
          if (storageStepScan.validUntil == null)
            errorMessage += "Date of Expiry' is empty.\n";
          return errorMessage;
          break;
        }

      case 2:
        //step 3(Atttestation)
        String errorMessage = "";
        return errorMessage;
        break;
    }
  }

  Widget showButtonNext(
      BuildContext context, int currentStep, Function functionOnStepContinue) {
    return Row(
      //mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 40),
            child: PlatformButton(
              padding: Platform.isIOS ? EdgeInsets.symmetric(horizontal: 0) : null,
              child: getButtonNextTitle(stepIndex: currentStep),
              onPressed: () {
                String errors = onButtonNextPressed(currentStep);
                //is button 'next' unlocked
                if (errors.isEmpty) {
                  functionOnStepContinue();
                } else {
                  showAlert(
                    context: context,
                    title: Text("Cannot continue"),
                    content: Text(errors + '\nPlease fill the form with valid data!')
                  );
                }
              },
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final stepperBloc = BlocProvider.of<StepperBloc>(context);
    return BlocBuilder(
      bloc: stepperBloc,
      builder: (BuildContext context, StepperState state) {
        return CustomStepper(
            currentStep: state.step,
            steps: widget.isMagnetLink == true ? getStepsMagnetLink(context) : getSteps(context),
            type: StepperType.vertical,
            onStepTapped: (step) {
              this.currentState = step;
              stepperBloc.add(StepTapped(step: step));
            },
            onStepCancel: () {
              this.currentState = state.step - 1;
              stepperBloc.add(StepCancelled());
            },
            onStepContinue: () {

              Storage storage = Storage();
              StepDataAttestation stepDataAttestation = storage.getStorageData(2);
              this.currentState = state.step + (stepDataAttestation.isOutsideCall && state.step == 1 ? 2 : 1);
              stepperBloc.add(StepContinue(stepsJump: stepDataAttestation.isOutsideCall && state.step == 1 ? 2 : 1));
            },
            controlsBuilder: (BuildContext context,
                {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
              return Visibility(
                  visible: state.step != state.maxSteps - 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      showButtonNext(context, state.step, onStepContinue)
                    ],
                  ));
            });
      },
    );
  }
}
