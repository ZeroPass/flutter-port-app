import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import "package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart";

class StepEnterAccountHeaderForm extends StatefulWidget {

  StepEnterAccountHeaderForm({Key key}) : super(key: key);

  @override
  _StepEnterAccountHeaderFormState createState() => _StepEnterAccountHeaderFormState();
}

class _StepEnterAccountHeaderFormState extends State<StepEnterAccountHeaderForm> {
  //Stepper steps

  _StepEnterAccountHeaderFormState({Key key});


  Widget deleteButton(BuildContext context, double size){
    final stepperBloc = BlocProvider.of<StepperBloc>(context);
    final stepEnterAccountHeaderBloc = BlocProvider.of<StepEnterAccountHeaderBloc>(context);
    final stepEnterAccountBloc = BlocProvider.of<StepEnterAccountBloc>(context);
    return SizedBox.fromSize(
      size: Size(size, size), // button width and height
      child: ClipOval(
        child: Material(
          //color: Colors.white, // button color
          child: InkWell(
            splashColor: Colors.green, // splash color
            onTap: () {
              stepperBloc.add(StepTapped(step: 0));
              stepEnterAccountBloc.add(AccountDelete());
              stepEnterAccountHeaderBloc.add(AccountRemoved());
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.remove_circle, color: Color(0xFFa58157)),
                //PlatformText("Del", style: TextStyle(fontWeight: FontWeight.normal)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stepEnterAccountHeaderBloc = BlocProvider.of<StepEnterAccountHeaderBloc>(context);
    print("header form");
    print("width");
    print(MediaQuery.of(context).size.width);
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
                      Container(child: Text("Account")),
                      if (state is AccountIDState) Container(child: Text("  ${state.accountID}", style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFFa58157)))),
                      //show only delete button when data is in the tab
                      if (state.showIconRemove) deleteButton(context, 40)
                    ],
                  )
              )
            ]
        );
      },
    );
  }
}
