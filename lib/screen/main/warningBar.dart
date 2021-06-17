import 'package:eosio_passid_mobile_app/constants/constants.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestationHeader/stepAttestationHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:eosio_passid_mobile_app/screen/requestType.dart';
import 'package:eosio_passid_mobile_app/utils/structure.dart';
import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/utils/size.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart';
import "package:eosio_passid_mobile_app/utils/storage.dart";
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScanHeader/stepScanHeader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';

class WarningBar extends StatefulWidget {
  OutsideCallV0dot1 outsideCall;

  WarningBar({required this.outsideCall});

  @override
  _WarningBarState createState() => _WarningBarState();
}

class _WarningBarState extends State<WarningBar> {
  _WarningBarState();


  static void deleteOutsideCallState(BuildContext context){
    final stepperBloc = BlocProvider.of<StepperBloc>(context);
    final stepScanHeaderBloc = BlocProvider.of<StepScanHeaderBloc>(context);
    final stepEnterAccountBloc = BlocProvider.of<StepEnterAccountBloc>(context);
    final stepEnterAccountHeaderBloc = BlocProvider.of<StepEnterAccountHeaderBloc>(context);
    final stepAttestationBloc = BlocProvider.of<StepAttestationBloc>(context);
    final stepAttestationHeaderBloc = BlocProvider.of<StepAttestationHeaderBloc>(context);
    final stepScanBloc = BlocProvider.of<StepScanBloc>(context);

    Storage storage = Storage();

    stepperBloc.add(StepTapped(step: 0, previousStep: 0));

    stepEnterAccountBloc.updateDataOnUI();
    stepEnterAccountHeaderBloc.updateDataOnUI();

    stepAttestationBloc.updateDataOnUI();
    stepAttestationHeaderBloc.updateDataOnUI();

    //remove outside call data
    storage.outsideCall.remove();

    //save storage
    storage.save();

    //change state on step main window
    stepScanBloc.add(NoDataScan());

    //change state on step header
    stepScanHeaderBloc.add(NoDataEvent());
  }

  Widget deleteButton(BuildContext context) {
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => deleteOutsideCallState(context));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(Icons.clear, color: Colors.white/*AndroidThemeST().getValues().themeValues["STEPPER"]["BUTTON_DELETE"]["COLOR_BACKGROUND"]*/)
            ],
          ),
        ),
      ),
      //),
    );
  }

  @override
  Widget build(BuildContext context) {

    return widget.outsideCall != null && widget.outsideCall.isOutsideCall?
              /*show the widget only if there is call from outside (QR or magnet link)*/
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal:DoubleUtil.fromInt(STEPPER_ICON_PADDING_TOP_DOWN_LEFT)),
                color: AndroidThemeST().getValues().themeValues["OUTSIDE_CALL"]["BAR_BACKGROUND_COLOR"],
                  width: CustomSize.getMaxWidth(context, 0),
                  child: Column(children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(children: <Widget>[
                              Text("Active request", style: TextStyle(fontWeight: FontWeight.bold, color: AndroidThemeST().getValues().themeValues["OUTSIDE_CALL"]["BAR_TEXT_COLOR"])),
                            ]),

                            Row(children: <Widget>[
                              Align( alignment: Alignment.centerRight,
                                    child: deleteButton(context))
                            ])
                        ]
                    )
                  ])
                )
                :
              /*Do not show anything*/
              Container();
  }
}