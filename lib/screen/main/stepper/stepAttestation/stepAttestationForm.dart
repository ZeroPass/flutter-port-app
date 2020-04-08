import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import "package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart";
import 'package:flutter/cupertino.dart';
import 'package:eosio_passid_mobile_app/utils/size.dart';
import 'package:eosio_passid_mobile_app/screen/nfc/authn.dart';
import 'package:eosio_passid_mobile_app/screen/customAlertDialog.dart';

class StepAttestationForm extends StatefulWidget {
  StepAttestationForm({Key key}) : super(key: key);

  @override
  _StepAttestationFormState createState() => _StepAttestationFormState();
}

class _StepAttestationFormState extends State<StepAttestationForm> {
  //Stepper steps

  _StepAttestationFormState({Key key}){}


  @override
  Widget build(BuildContext context) {
    Storage storage = Storage();

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final stepAttestiationBloc = BlocProvider.of<StepAttestationBloc>(context);
    final stepperBloc = BlocProvider.of<StepperBloc>(context);

    return BlocBuilder(
      bloc: stepAttestiationBloc,
      builder: (BuildContext context, StepAttestationState state) {

        return Container(
            width: CustomSize.getMaxWidth(context, STEPPER_ICON_PADDING),
            child:Form(
                key: _formKey,
                autovalidate: true,
                child: Authn())
        );
      },
    );
  }
}
