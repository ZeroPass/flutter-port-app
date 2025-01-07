import 'package:port_mobile_app/screen/requestType.dart';
import 'package:port_mobile_app/utils/structure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:port_mobile_app/screen/main/stepper/stepAttestation/stepAttestationHeader/stepAttestationHeader.dart';
import 'package:port_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:flutter/cupertino.dart';
import "package:port_mobile_app/screen/main/stepper/stepper.dart";
import 'package:port_mobile_app/screen/customChip.dart';
import 'package:port_mobile_app/utils/storage.dart';
import 'package:port_mobile_app/utils/size.dart';

class StepAttestationHeaderForm extends StatefulWidget {
  StepAttestationHeaderForm() : super();

  @override
  _StepAttestationHeaderFormState createState() => _StepAttestationHeaderFormState();
  }

class _StepAttestationHeaderFormState extends State<StepAttestationHeaderForm> {
  _StepAttestationHeaderFormState();
  @override
  Widget build(BuildContext context) {
    final stepAttestationHeaderBloc =
        BlocProvider.of<StepAttestationHeaderBloc>(context);
    return BlocBuilder(
      bloc: stepAttestationHeaderBloc,
      builder: (BuildContext context, StepAttestationHeaderState state) {
        return Container(
            width: CustomSize.getMaxWidth(context, STEPPER_ICON_PADDING),
            child: Column(children: <Widget>[
                  Row(children: <Widget>[
                    Text("Request type "),
                    //Text(AuthenticatorActions[state.requestType]),
                    if (state is AttestationHeaderWithDataState)
                      Container(child: CustomChip(titles:[AuthenticatorActions[state.requestType]['NAME']]), margin: EdgeInsets.only(left: 3.0)),
                    if (state is AttestationHeaderWithDataOutsideCallState)
                      Container(child: CustomChip(titles:[AuthenticatorActions[state.requestType]['NAME']]), margin: EdgeInsets.only(left: 3.0))

                  ]),
            ]
          ));
      },
    );
  }
}
