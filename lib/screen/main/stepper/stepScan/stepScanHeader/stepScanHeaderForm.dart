import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScanHeader/stepScanHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:flutter/cupertino.dart';
import "package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart";
import 'package:eosio_passid_mobile_app/screen/customChip.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/utils/size.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import "package:intl/intl.dart";

class StepScanHeaderForm extends StatefulWidget {
  StepScanHeaderForm({Key key}) : super(key: key);

  @override
  _StepScanHeaderFormState createState() =>
      _StepScanHeaderFormState();
}

class _StepScanHeaderFormState
    extends State<StepScanHeaderForm> {
  //Stepper steps

  _StepScanHeaderFormState({Key key});

  Widget deleteButton(BuildContext context) {
    final stepperBloc = BlocProvider.of<StepperBloc>(context);
    final stepScanHeaderBloc = BlocProvider.of<StepScanHeaderBloc>(context);
    final stepScanBloc = BlocProvider.of<StepScanBloc>(context);
    var storage = Storage();
    StepDataScan storageStepScan = storage.getStorageData(1);
    return ClipOval(
      child: Material(
        //color: Colors.white, // button color
        child: InkWell(
          hoverColor: Colors.black,
          splashColor: Colors.green,
          // splash color
          focusColor: Colors.green,
          highlightColor: Colors.green,
          onTap: () {
            //change state on stepper
            stepperBloc.add(StepTapped(step: 1));

            //update selected node in storage
            storageStepScan.documentID = null;
            storageStepScan.validUntil = null;
            storageStepScan.birth = null;

            //save storage
            storage.save();

            //change state on step main window
            stepScanBloc.add(NoDataScan());

            //change state on step header
            stepScanHeaderBloc.add(NoDataEvent());
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(Icons.remove_circle, color: AndroidThemeST().getValues().themeValues["STEPPER"]["BUTTON_DELETE"]["COLOR_BACKGROUND"])
            ],
          ),
        ),
      ),
      //),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stepScanHeaderBloc =
    BlocProvider.of<StepScanHeaderBloc>(context);
    //final stepEnterAccountBloc = BlocProvider.of<StepEnterAccountBloc>(context);
    return BlocBuilder(
      bloc: stepScanHeaderBloc,
      builder: (BuildContext context, StepScanHeaderState state) {
        return Container(
            width: CustomSize.getMaxWidth(context, STEPPER_ICON_PADDING),
            child: Column(children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Text("Passport Info"),
                    Row(children: <Widget>[
                      Transform(
                        alignment: Alignment.centerRight,
                        transform: new Matrix4.identity()..scale(0.8),
                        child: Row(children: <Widget>[
                          if (state is WithDataState && state.documentID != null && state.documentID.length > 0)
                            Container(child: CustomChip(['No.']), margin: EdgeInsets.only(left: 3.0)),
                          if (state is WithDataState && state.birth != null)
                            Container(child: CustomChip(['Birth']), margin: EdgeInsets.only(left: 3.0)),
                          if (state is WithDataState && state.validUntil != null)
                            Container(child: CustomChip(['Expiry']), margin: EdgeInsets.only(left: 3.0)),

                    ])
                    ),

                    if (state is WithDataState)
                      Align(
                      alignment: Alignment.centerRight,
                      child: deleteButton(context))
                  ],
              )
            ]
              )]
              //)
            ));
      },
    );
  }
}
