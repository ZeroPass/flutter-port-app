import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import "package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScan.dart";
import "package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart";
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_passid_mobile_app/screen/customDatePicker.dart';

class StepScanForm extends StatefulWidget {
  StepScanForm({Key key}) : super(key: key);

  @override
  _StepScanFormState createState() => _StepScanFormState();
}

class _StepScanFormState extends State<StepScanForm> {
  //Stepper steps

  _StepScanFormState({Key key});

  @override
  Widget build(BuildContext context) {
    TimeOfDay _timeOfDay = new TimeOfDay(hour: 10, minute: 10);

    Function _updateTimeFunction;
    print("_StepperEnterAccountFormState");
    TextEditingController accountTextController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final stepScanBloc = BlocProvider.of<StepScanBloc>(context);

    return BlocBuilder(
      bloc: stepScanBloc,
      builder: (BuildContext context, StepScanState state) {
        return Form(

            key: _formKey,
            autovalidate: true,
            child: Column(children: <Widget>[
              CustomDatePicker(),

              TextFormField(
                  //maxLength: 12,
                  controller: accountTextController,
                  decoration: InputDecoration(
                    //border: InputBorder.none,
                    labelText: 'Valid from',
                  ),
                  autofocus: true,
                  validator: (value) =>
                      stepScanBloc.validatorFunction(value, context)
                          ? stepScanBloc.validatorText
                          : null,
                  onChanged: (value) {
                    if (accountTextController.text != value.toLowerCase())
                      accountTextController.value = accountTextController.value
                          .copyWith(text: value.toLowerCase());
                  }),

              TextFormField(
                //maxLength: 12,
                  controller: accountTextController,
                  decoration: InputDecoration(
                    //border: InputBorder.none,
                    labelText: 'Valid to',
                  ),
                  autofocus: true,
                  validator: (value) =>
                  stepScanBloc.validatorFunction(value, context)
                      ? stepScanBloc.validatorText
                      : null,
                  onChanged: (value) {
                    if (accountTextController.text != value.toLowerCase())
                      accountTextController.value = accountTextController.value
                          .copyWith(text: value.toLowerCase());
                  }),

            Padding(padding: EdgeInsets.only(bottom: 20), child:TextFormField(
                //maxLength: 12,
                  controller: accountTextController,
                  decoration: InputDecoration(
                    //border: InputBorder.none,
                    labelText: 'Passport number',
                  ),
                  autofocus: true,
                  validator: (value) =>
                  stepScanBloc.validatorFunction(value, context)
                      ? stepScanBloc.validatorText
                      : null,
                  onChanged: (value) {
                    if (accountTextController.text != value.toLowerCase())
                      accountTextController.value = accountTextController.value
                          .copyWith(text: value.toLowerCase());
                  }))
            ]));
      },
    );
  }
}
