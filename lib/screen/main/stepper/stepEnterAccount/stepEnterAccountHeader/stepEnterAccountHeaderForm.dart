import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:flutter/cupertino.dart';
import "package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart";
import 'package:eosio_passid_mobile_app/screen/customChip.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/utils/size.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';

class StepEnterAccountHeaderForm extends StatefulWidget {
  StepEnterAccountHeaderForm({Key key}) : super(key: key);

  @override
  _StepEnterAccountHeaderFormState createState() =>
      _StepEnterAccountHeaderFormState();
}

class _StepEnterAccountHeaderFormState
    extends State<StepEnterAccountHeaderForm> {
  //Stepper steps

  _StepEnterAccountHeaderFormState({Key key});

  Widget deleteButton(BuildContext context) {
    final stepperBloc = BlocProvider.of<StepperBloc>(context);
    final stepEnterAccountHeaderBloc =
        BlocProvider.of<StepEnterAccountHeaderBloc>(context);
    final stepEnterAccountBloc = BlocProvider.of<StepEnterAccountBloc>(context);
    var storage = Storage();
    return ClipOval(
      child: Material(
        //color: Colors.white, // button color
        child: InkWell(
          hoverColor: Colors.black,
          splashColor: Colors.green,
          // splash color
          focusColor: Colors.green,
          highlightColor: Colors.green,
          onTap: () {
            //change state on stepper
            stepperBloc.add(StepTapped(step: 0));
            //change state on step main window
            stepEnterAccountBloc.add(AccountDelete());

            //update selected node in storage
            storage.selectedNode = storage.getDefaultNode();

            //change state on step header
            stepEnterAccountHeaderBloc.add(WithoutAccountIDEvent(
                network: storage.getSelectedNode(), server: storage.getStorageServer()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(Icons.remove_circle, color: AndroidThemeST().getValues().themeValues["STEPPER"]["BUTTON_DELETE"]["COLOR_BACKGROUND"])
            ],
          ),
        ),
      ),
      //),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stepEnterAccountHeaderBloc =
        BlocProvider.of<StepEnterAccountHeaderBloc>(context);
    //final stepEnterAccountBloc = BlocProvider.of<StepEnterAccountBloc>(context);
    return BlocBuilder(
      bloc: stepEnterAccountHeaderBloc,
      builder: (BuildContext context, StepEnterAccountHeaderState state) {
        return Container(
            width: CustomSize.getMaxWidth(context, STEPPER_ICON_PADDING),
            child: Column(children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(children: <Widget>[
                    Text("Account"),
                    Container(child: CustomChip([state.network.name])),
                  ]),
                  Row(children: <Widget>[
                    if (state is WithAccountIDState)
                      Container(child: CustomChip([state.accountID])),
                    if (state.server != null)
                      Align(
                          alignment: Alignment.centerRight,
                          child:
                          Container(child: CustomChip(["SERVER"]))),
                    if (state is WithAccountIDState)
                      Align(
                          alignment: Alignment.centerRight,
                          child: deleteButton(context))
                  ])
                ],
              )
            ]
                //)
                ));
      },
    );
  }
}
