import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import "package:eosign_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart";
import "package:eosign_mobile_app/screen/main/stepper/stepper.dart";
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class StepEnterAccountForm extends StatefulWidget {
  final int temp;

  StepEnterAccountForm({Key key, @required this.temp}) : super(key:key);

  @override
  _StepEnterAccountFormState createState() => _StepEnterAccountFormState(temp: temp);
}


class _StepEnterAccountFormState extends State<StepEnterAccountForm> {
  //Stepper steps
  final int temp;

  _StepEnterAccountFormState({Key key, @required this.temp});


  @override
  Widget build(BuildContext context) {
    TimeOfDay _timeOfDay = new TimeOfDay(hour: 10, minute: 10);

    Function _updateTimeFunction;
    print("_StepperEnterAccountFormState");
    TextEditingController accountTextController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final stepEnterAccountBloc = BlocProvider.of<StepEnterAccountBloc>(context);

    return BlocBuilder(
        bloc: stepEnterAccountBloc,
        builder: (BuildContext context, StepEnterAccountState state){
        return Form(
        key: _formKey,
        autovalidate: true,
        child: TextFormField(
          //maxLength: 12,
            controller: accountTextController,
            decoration: InputDecoration(
              //border: InputBorder.none,
              labelText: 'Account name',
            ),
            //inputFormatters: [
            //  WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-5.]")),
            //],
            autofocus: true,
            validator:  (value) => stepEnterAccountBloc.validatorFunction(value, context) ? stepEnterAccountBloc.validatorText : null/*(String value) {
                if (RegExp("^[a-z1-5.]{0,12}[a-p]\$").hasMatch(value) == false){
                  return 'You type not allowed character';
                }
                if (value.length > 12) {
                  return 'Account name cannot be longer than 12 characters';
                }
                else if (value.length > 5){
                  Future<bool> kvaje = stepEnterAccountBloc.accountExists(value);
                  print(kvaje);
                  kvaje.then((value) {
                    print(value);
                    return ("there si something");
                  }, onError: (error) {
                    print('completed with error $error');
                  });
                };
                  //if (!stepEnterAccountBloc.accountExists(value).){
                  //}
                  final stepperBloc = BlocProvider.of<StepperBloc>(context);
                return null;
              }*/
            ,
            onChanged: (value) {
              if (accountTextController.text != value.toLowerCase())
                accountTextController.value =
                    accountTextController.value.copyWith(
                        text: value.toLowerCase());
            }
        )

    );
  },
  );
}
}