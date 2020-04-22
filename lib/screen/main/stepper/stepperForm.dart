import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart";
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScanHeader/stepScanHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import 'package:eosio_passid_mobile_app/screen/customAlertDialog.dart';

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
        }
        break;

      default:
        FocusScope.of(context).requestFocus(FocusNode());
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
              child: Text('Continue', style: TextStyle(color: Colors.white)),
              onPressed: () {
                String errors = onButtonNextPressed(currentStep);
                //is button 'next' unlocked
                if (errors.isEmpty) {
                  functionOnStepContinue();
                } else {
                  CustomAlertDialog(context, "Cannot continue",
                      errors + '\nPlease fill the form with valid data.', () {
                    print("button pressed");
                  });
                  /*showPlatformDialog(
              context: context,
              builder: (_) => PlatformAlertDialog(
                title: Text('Cannot continue'),
                content: Text(errors + '\nPlease fill the form with valid data.'),
                actions: <Widget>[
                  PlatformDialogAction(
                      child: PlatformText('OK', style: TextStyle(color: AndroidThemeST().getValues().themeValues["STEPPER"]["STEPPER_MANIPULATOR"]["COLOR_TEXT"])),
                      onPressed: () => Navigator.pop(context)
                  )
                ],
              ),
            );*/
                }
              }, /**/
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
        print(MaterialLocalizations.of(context));
        return Stepper(
            currentStep: state.step,
            steps: steps,
            type: StepperType.vertical,
            onStepTapped: (step) {
              //stepperBloc.modifyHeader(state.step, step, context);
              stepperBloc.add(StepTapped(step: step));
            },
            onStepCancel: () {
              stepperBloc.add(StepCancelled());
            },
            onStepContinue: () {
              //stepperBloc.modifyHeader(state.step, state.step + 1, context);
              stepperBloc.add(StepContinue());
            },
            controlsBuilder: (BuildContext context,
                {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
              return Visibility(
                  visible: state.step != 2,
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
