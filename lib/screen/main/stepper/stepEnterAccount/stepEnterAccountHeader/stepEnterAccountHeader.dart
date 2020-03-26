export 'stepEnterAccountHeaderBloc.dart';
export 'stepEnterAccountHeaderEvent.dart';
export 'stepEnterAccountHeaderForm.dart';
export 'stepEnterAccountHeaderState.dart';

/*
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import "package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart";
import 'package:eosio_passid_mobile_app/screen/customChip.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';

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
    var storage = Storage();
    return /*SizedBox.fromSize(
      size: Size(size, size), // button width and height
      child: */ClipOval(
      child: Material(
        //color: Colors.white, // button color
        child: InkWell(
          hoverColor: Colors.black,
          splashColor: Colors.green, // splash color
          focusColor: Colors.green,
          highlightColor: Colors.green,
          onTap: () {
            stepperBloc.add(StepTapped(step: 0));
            stepEnterAccountBloc.add(AccountDelete());
            stepEnterAccountHeaderBloc.add(WithoutAccountIDEvent(network: storage.getSelectedNode(), server: storage.getStorageServer() ));
          },
          child: Column(

            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(Icons.remove_circle, color: Color(0xFFa58157))
            ],
          ),
        ),
      ),
      //),
    );
  }

  @override
  void setState(fn) {
    // TODO: implement setState
    print("set state in accountHeaderForm");
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
            children: <Widget>[
              Container(
                  width: MediaQuery.of(context).size.width * 0.79,
                  alignment: Alignment.centerRight,
                  child:Row(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        //crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text("Account"),
                            Container(child: CustomChip([ 'EOS'])),

                          ]),

                      Row(
                        //crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            //Text("Account"),
                            //Container(child: CustomChip(['one', 'two'])),
                            if (state is WithAccountIDState)
                              Container(child: CustomChip([ '${state.accountID}'])),
                            if (state is WithAccountIDState)
                              Align(alignment: Alignment.centerRight, child: deleteButton(context, 40))
                          ])
                    ],
                  )
              )
            ]


    );
  }
}
*/