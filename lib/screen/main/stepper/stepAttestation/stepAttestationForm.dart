import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/utils/structure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import "package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart";
import 'package:eosio_passid_mobile_app/screen/requestType.dart';
import 'package:eosio_passid_mobile_app/screen/customBottomPicker.dart';
import 'package:flutter/cupertino.dart';
import 'package:eosio_passid_mobile_app/utils/size.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';

class StepAttestationForm extends StatefulWidget {
  StepAttestationForm({Key key}) : super(key: key);

  @override
  _StepAttestationFormState createState() => _StepAttestationFormState();
}

void selectRequestType(var context,
                        StepAttestationState state,
                        var stepAttestationBloc) {
  var storage = Storage();
  StepDataAttestation storageAttestation = storage.getStorageData(2);
  BottomPickerStructure bps = BottomPickerStructure();
  bps.importStorageRequestList(AuthenticatorActions, storageAttestation.requestType,
      "Select request type",
      "Please select request type");
  CustomBottomPickerState cbps = CustomBottomPickerState(structure: bps);
  cbps.showPicker(context,
      //callback function to manage user click action on selection
          (BottomPickerElement returnedElement) {
            storageAttestation.requestType = EnumUtil.fromStringEnum(RequestType.values, returnedElement.key);
            storage.save();

            if (state is AttestationWithDataState) {
              stepAttestationBloc.add(AttestationWithDataEvent(requestType: storageAttestation.requestType));
            }

            //also update header - its way around because we can not access to header directly from this object
            final stepperBloc = BlocProvider.of<StepperBloc>(context);
            stepperBloc.liveModifyHeader(2, context);
          });
}

Widget selectRequestTypeWithTile(var context,
                              StepAttestationState state,
                              var stepAttestationBloc) {
  var storage = Storage();
  StepDataAttestation stepDataAttestation = storage.getStorageData(2);
  return ListTile(
    dense: true,
    contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
    title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Request type',
            style: TextStyle(
                fontSize: AndroidThemeST().getValues().themeValues["TILE_BAR"]
                ["SIZE_TEXT"]),
          ),
          Text(  AuthenticatorActions[stepDataAttestation.requestType]["NAME"],
              style: TextStyle(
                  fontSize: AndroidThemeST()
                      .getValues()
                      .themeValues["TILE_BAR"]["SIZE_TEXT"],
                  color: AndroidThemeST().getValues().themeValues["TILE_BAR"]
                  ["COLOR_TEXT"]))
        ]),
    trailing: Icon(Icons.expand_more),
    onTap: () => selectRequestType(context, state, stepAttestationBloc),
  );
}


Widget dataDescription(var context) {
  Storage storage = Storage();
  StepDataAttestation stepDataAttestation = storage.getStorageData(2);

  return Container(
      alignment: Alignment.centerLeft,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                child: Text('Data Sent',
                    style: TextStyle(
                      fontSize:AndroidThemeST()
                        .getValues()
                        .themeValues["STEPPER"]["STEP_TAP"]["SIZE_TEXT"])),
                margin: EdgeInsets.only(bottom: 10.0)),
            for (var item in AuthenticatorActions[stepDataAttestation.requestType]["DATA"])
              Container(
                  child: Text('  • ' + item,
                      style: TextStyle(
                          fontSize: AndroidThemeST()
                              .getValues()
                              .themeValues["STEPPER"]["STEP_TAP"]["SIZE_TEXT"] - 2,
                          color: AndroidThemeST()
                              .getValues()
                              .themeValues["STEPPER"]["STEP_TAP"]["COLOR_TEXT"])),
                  margin: EdgeInsets.only(left: 0.0))
          ]));
}


class _StepAttestationFormState extends State<StepAttestationForm> {

  _StepAttestationFormState({Key key}){}

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final stepAttestiationBloc = BlocProvider.of<StepAttestationBloc>(context);

    return BlocBuilder(
      bloc: stepAttestiationBloc,
      builder: (BuildContext context, StepAttestationState state) {

        return Container(
            width: CustomSize.getMaxWidth(context, STEPPER_ICON_PADDING),
            child: Column(
                  children: <Widget>[
                    selectRequestTypeWithTile(context, state, stepAttestiationBloc),
                    dataDescription(context),
                  ],
              )
        );
      },
    );
  }
}
