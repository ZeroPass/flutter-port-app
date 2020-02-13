import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import "package:eosign_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart";
import "package:eosign_mobile_app/screen/main/stepper/stepper.dart";
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosign_mobile_app/utils/storage.dart';

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
            validator:  (value) => stepEnterAccountBloc.validatorFunction(value, context) ? stepEnterAccountBloc.validatorText : null
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

//header

/*
class StepEnterAccountHeader1 extends StatefulWidget {
  String account;

  StepEnterAccountHeader1({Key key, this.account}) : super(key:key);

  @override
  _StepEnterAccountHeaderForm1 createState() => _StepEnterAccountHeaderForm1();
}


class _StepEnterAccountHeaderForm1 extends State<StepEnterAccountHeader1> {
  StepDataEnterAccount storageStepEnterAccount = Storage().getStorageData(0);
  String accountID = '';

  _StepEnterAccountHeaderForm1({Key key, this.accountID = ''});
  //storageStepEnterAccount.

  void changeAccountID({String account = ''}) {
    setState(() {
      this.accountID = account;
    });
  }

  @override
  Widget build(BuildContext context) {
    //final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    //final stepEnterAccountBloc = BlocProvider.of<StepEnterAccountBloc>(context);
    print("a");
    print (this.accountID);
    print("b");
    return Column(
        children: <Widget>[
      Container(
      width: MediaQuery.of(context).size.width * 0.6,
        alignment: Alignment.bottomRight,
        child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(child: PlatformText("Account")),
          Container(child: (this.accountID  != '' ) ? PlatformText(" ("+ this.accountID +") ") : PlatformText("")),
          Container(
              child: Align(
              alignment: Alignment.bottomRight,
              child:Icon(context.platformIcons.delete)))
        ],
        )
    )
        ]
    );
  }
}*/