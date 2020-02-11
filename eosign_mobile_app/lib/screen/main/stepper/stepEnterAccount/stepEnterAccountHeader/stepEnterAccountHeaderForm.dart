import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:eosign_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class StepEnterAccountHeaderForm extends StatefulWidget {

  StepEnterAccountHeaderForm({Key key}) : super(key: key);

  @override
  _StepEnterAccountHeaderFormState createState() => _StepEnterAccountHeaderFormState();
}

class _StepEnterAccountHeaderFormState extends State<StepEnterAccountHeaderForm> {
  //Stepper steps

  _StepEnterAccountHeaderFormState({Key key});

  @override
  Widget build(BuildContext context) {
    final stepEnterAccountHeaderBloc = BlocProvider.of<StepEnterAccountHeaderBloc>(context);
    print("header form");
    return BlocBuilder(
      bloc: stepEnterAccountHeaderBloc,
      builder: (BuildContext context, StepEnterAccountHeaderState state) {
        print(state.toString());
        return Column(
            children: <Widget>[
              Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  alignment: Alignment.bottomRight,
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(child: PlatformText("Account")),
                      Container(child:  state is AccountIDState? PlatformText(" ( ${state.accountID} ) "): PlatformText("empty")),
                      Container(
                          child: Align(
                              alignment: Alignment.bottomRight,
                              child:Icon(context.platformIcons.delete)))
                    ],
                  )
              )
            ]
        );
      },
    );
  }
}
