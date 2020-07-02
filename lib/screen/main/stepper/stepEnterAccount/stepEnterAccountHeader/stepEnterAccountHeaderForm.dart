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
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class StepEnterAccountHeaderForm extends StatefulWidget {
  StepEnterAccountHeaderForm({Key key}) : super(key: key);

  @override
  _StepEnterAccountHeaderFormState createState() =>
      _StepEnterAccountHeaderFormState();
}

class _StepEnterAccountHeaderFormState extends State<StepEnterAccountHeaderForm> {
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
            //change state on stepper - action removed
            //stepperBloc.add(StepTapped(step: 0));

            //change state on step main window
            stepEnterAccountBloc.add(AccountDelete(network: storage.getNode()));

            //update selected node in storage
            storage.selectedNode = storage.getDefaultNode();

            StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0);
            storageStepEnterAccount.accountID = null;

            //save
            storage.save();

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

  String truncateNetwork(String networkName, int length)
  {
    if (length < 0)
      return networkName;
    //we check with length + 3 because of three dots
    if (networkName.length > length + 3)
    {
      networkName = networkName.substring(0, networkName.indexOf(" ") > 0? networkName.indexOf(" "): networkName.length);
      if (networkName.length > length)
        return networkName.substring(0, length) + "...";
      return networkName;
    }
    return networkName;
  }

  String truncateAccountName(String accountName, int length)
  {
    if (length < 0)
      return accountName;
    //we check with length + 3 because of three dots
    if (accountName.length > length + 3)
        return accountName.substring(0, length) + "...";
    return accountName;
  }

  @override
  Widget build(BuildContext context) {
    final stepEnterAccountHeaderBloc =
        BlocProvider.of<StepEnterAccountHeaderBloc>(context);
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
                    Transform(
                        alignment: Alignment.centerLeft,
                        transform: new Matrix4.identity()..scale(0.8),
                        child: Container(child: CustomChip([truncateNetwork(state.network.name, 5)]), margin: EdgeInsets.only(left: 3.0))
                    ),
                  ]),
                  Row(children: <Widget>[
                    Transform(
                        alignment: Alignment.centerRight,
                        transform: new Matrix4.identity()..scale(0.8),
                        child: Row(
                            mainAxisAlignment:MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                                if (state is WithAccountIDState)
                                  if(state.network.notBlockchain == false && state.accountID != null)
                                    Container(child: CustomChip([truncateAccountName(state.accountID, 6)]), margin: EdgeInsets.only(left: 3.0)),
                                //if (state.server != null)
                                //  Container(child: CustomChip(["SERVER"]), margin: EdgeInsets.only(left: 3.0)),
                                ])),
                    if (state is WithAccountIDState && state.network.notBlockchain == false)
                      deleteButton(context)
                  ])
                ],
              )
            ]
          ));
      },
    );
  }
}
