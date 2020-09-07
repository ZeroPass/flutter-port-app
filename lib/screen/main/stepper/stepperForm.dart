import 'dart:io';

import 'dart:async';
import 'package:dmrtd/internal.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestationHeader/stepAttestationHeader.dart';
import 'package:eosio_passid_mobile_app/screen/nfc/authn/authn.dart';
import 'package:eosio_passid_mobile_app/screen/requestType.dart';
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
import 'package:eosio_passid_mobile_app/utils/structure.dart';
import "package:eosio_passid_mobile_app/screen/main/stepper/customStepper.dart";
import 'package:eosio_passid_mobile_app/screen/nfc/authn/authn.dart';
import 'package:eosio_passid_mobile_app/screen/nfc/efdg1_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dmrtd/dmrtd.dart';

import '../../alert.dart';

List<String> BUTTON_NEXT_TITLE = [
  "Continue",
  "Scan Passport",
  "Scan Passport",
  ""
];

Widget getButtonNextTitle({@required int stepIndex}) {
  if (stepIndex > BUTTON_NEXT_TITLE.length - 1)
    throw FormatException("step index is larger than number of all steps");
  return Text(BUTTON_NEXT_TITLE.elementAt(stepIndex));
}

class StepperForm extends StatefulWidget {
  bool isMagnetLink;

  StepperForm({isMagnetLink = null}) {
    this.isMagnetLink =
        isMagnetLink == null || isMagnetLink == false ? false : true;
  }

  @override
  _StepperFormState createState() => _StepperFormState();
}

class _StepperFormState extends State<StepperForm> {
  List<StepState> listState = [
    StepState.indexed,
    StepState.editing,
  ];

  StepState _getState(int step, int currentStep, {isLastStep = false}) {
    if (currentStep == step)
      return StepState.editing;
    else if (isLastStep)
      return StepState.disabled;
    else
      return StepState.indexed;
  }

  //Stepper steps
  List<Step> getSteps(
      BuildContext context, int currentStep) {
    return <Step>[
      Step(
          title: StepEnterAccountHeaderForm(),
          content: StepEnterAccountForm(),
          state: _getState(0, currentStep),
          isActive: true),
      Step(
          title: StepScanHeaderForm(),
          content: StepScanForm(),
          state: _getState(1, currentStep),
          isActive: true),
      Step(
          title: StepAttestationHeaderForm(),
          content: StepAttestationForm(),
          state: _getState(2, currentStep),
          isActive: true),
      Step(
        title: StepReviewHeaderForm(),
        content: StepReviewForm(),
        state: _getState(3, currentStep, isLastStep: true),
        isActive: (3 == currentStep ? true : false)
        //isActive: false
      )
    ];
  }

  List<Step> getStepsMagnetLink(
      BuildContext context, int currentStep) {
    return <Step>[
      Step(
        title: StepEnterAccountHeaderForm(),
        content: StepEnterAccountForm(),
        state: _getState(0, currentStep),
      ),
      Step(
        title: StepScanHeaderForm(),
        content: StepScanForm(),
        state: _getState(1, currentStep),
      ),
      Step(
        title: Text("Attestation"),
        content: StepAttestationForm(),
        state: _getState(2, currentStep),
      ) /*,
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
              padding:
                  Platform.isIOS ? EdgeInsets.symmetric(horizontal: 0) : null,
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
                      content: Text(
                          errors + '\nPlease fill the form with valid data!'));
                }
              },
            ))
      ],
    );
  }

  Future<bool> _showDG1Dialog(BuildContext context, final EfDG1 dg1,
      {String msg = null}) async {
    //final authnBloc = BlocProvider.of<AuthnBloc>(context);
    Storage storage = new Storage();
    StepDataAttestation stepDataAttestation = storage.getStorageData(2);

    StepperBloc stepperBloc = BlocProvider.of<StepperBloc>(context);
    StepReviewBloc stepReviewBloc = BlocProvider.of<StepReviewBloc>(context);

    stepperBloc.add(StepRunByFlow(
        step: stepperBloc.state.maxSteps - 1 /*last step*/,
        previousStep: stepperBloc.state.step));
    //change header in stepper
    stepperBloc.liveModifyHeader(3, context, dataInStep: true);

    Completer<bool> send = new Completer<bool>();
    stepReviewBloc.add(StepReviewWithDataEvent(
        dg1: dg1,
        msg: msg,
        outsideCall: stepDataAttestation.isOutsideCall,
        sendData: (bool isDataSent) {
          send.complete(isDataSent);
        }));
    return send.future;
  }

  Future<bool> _showEFDG1(
    BuildContext context,
  ) async {
    String title;
    String msg;
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none ||
        !await testConnection()) {
      title = 'No Internet connection';
      msg = 'An internet connection is required!';
    } else {
      //settingsAction = () => _settingsButton.onPressed();
      title = 'Connection error';
      msg = 'Failed to connect to server.\n'
          'Check server connection settings.';
    }
    return showAlert<bool>(
        context: context,
        title: Text(title),
        content: Text(msg),
        actions: [
          PlatformDialogAction(
              child: PlatformText('Close',
                  style: TextStyle(
                      color: Theme.of(context).errorColor,
                      fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pop(context, false))
        ]);
  }

  bool isStepNFC(var stepperBloc, int stepJumps) {
    return (stepperBloc.state.step + stepJumps == stepperBloc.state.maxSteps - 1
        ? //is last step
        true
        : false);
  }

  void callNFC(BuildContext context, var stepperBloc) {
    Authn authn = Authn(
        /*show DG1 step*/
        onDG1FileRequested: (EfDG1 dg1) {
      return _showDG1Dialog(context, dg1);
    },
        /*show connection error*/
        onConnectionError: (SocketException e) async {
      return _showEFDG1(context);
    });
    authn.startNFCAction(context).then((bool value) {
      stepperBloc.add(StepBackToPrevious());
      //review header; cleaning process
      stepperBloc.liveModifyHeader(3, context, dataInStep: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final stepperBloc = BlocProvider.of<StepperBloc>(context);
    return BlocBuilder(
      bloc: stepperBloc,
      builder: (BuildContext context, StepperState state) {
        return CustomStepper(
            currentStep: state.step,
            steps: widget.isMagnetLink == true
                ? getStepsMagnetLink(context, state.step)
                : getSteps(context, state.step),
            type: StepperType.vertical,
            onStepTapped: (step) {
              stepperBloc.add(StepTapped(step: step));
            },
            onStepCancel: () {
              stepperBloc.add(StepCancelled());
            },
            onStepContinue: () {
              Storage storage = Storage();
              StepDataAttestation stepDataAttestation = storage.getStorageData(2);

              int stepJumps = stepDataAttestation.isOutsideCall.isOutsideCall &&
                      state.step == 1 ? 2 : 1;
              if (this.isStepNFC(stepperBloc, stepJumps))
                callNFC(context, stepperBloc);
              else
                stepperBloc.add(StepContinue(stepsJump: stepJumps));
            },
            controlsBuilder: (BuildContext context,
                {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
              return Visibility(
                  visible: state.step != state.maxSteps,
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
