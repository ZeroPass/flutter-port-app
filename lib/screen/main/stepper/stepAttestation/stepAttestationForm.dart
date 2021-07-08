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
  StepAttestationForm() : super();

  @override
  _StepAttestationFormState createState() => _StepAttestationFormState();
}

void selectRequestType(var context,
                        StepAttestationState state,
                        var stepAttestationBloc) {
  var storage = Storage();
  StepDataAttestation storageAttestation = storage.getStorageData(2) as StepDataAttestation;
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

String truncateRequestType(RequestType requestType, int length)
{
  if (requestType == null || MapUtil.contains(AuthenticatorActions, requestType) == false)
    throw Exception("StepAttestationForm:truncateRequestType; not valid AuthenticatorAction");

  String requestTypeStr = AuthenticatorActions[requestType]["NAME"];
  if (length < 0)
    return requestTypeStr;
  //we check with length + 3 because of three dots
  if (requestTypeStr.length > length + 3)
    if (requestTypeStr.length > length)
      return requestTypeStr.substring(0, length) + "...";
  return requestTypeStr;
}

Widget selectRequestTypeWithTile(var context,
                              StepAttestationState state,
                              var stepAttestationBloc) {
  RequestType requestType = RequestType.LOGIN;
  if (state is AttestationWithDataState)
    requestType = state.requestType;
  else if (state is AttestationWithDataOutsideCallState)
    requestType = state.requestType;

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
          Text(truncateRequestType(requestType, 10),
              style: TextStyle(
                  fontSize: AndroidThemeST()
                      .getValues()
                      .themeValues["TILE_BAR"]["SIZE_TEXT"],
                  color: AndroidThemeST().getValues().themeValues["TILE_BAR"]
                  ["COLOR_TEXT"]))
        ]),
    trailing: (!(state is AttestationWithDataOutsideCallState)) ?Icon(Icons.expand_more) : null,
    onTap: () {
      if (!(state is AttestationWithDataOutsideCallState))
        selectRequestType(context, state, stepAttestationBloc);
    },
  );
}


Widget dataDescription(var context) {
  Storage storage = Storage();
  StepDataAttestation stepDataAttestation = storage.getStorageData(2) as StepDataAttestation;

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

  _StepAttestationFormState(){}

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final stepAttestiationBloc = BlocProvider.of<StepAttestationBloc>(context);

    return BlocBuilder(
      bloc: stepAttestiationBloc,
      builder: (BuildContext context, StepAttestationState state) {

        return Container(
            width: CustomSize.getMaxWidth(context, STEPPER_ICON_PADDING),
            child: Column(
                  children: <Widget>[
                    selectRequestTypeWithTile(context, state, stepAttestiationBloc),
                    if (!(state is AttestationWithDataOutsideCallState))
                      dataDescription(context),
                  ],
              )
        );
      },
    );
  }
}
