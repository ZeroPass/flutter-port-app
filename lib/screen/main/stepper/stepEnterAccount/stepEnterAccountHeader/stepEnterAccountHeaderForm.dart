import 'package:eosio_passid_mobile_app/constants/constants.dart';
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

class StepEnterAccountHeaderForm extends StatefulWidget {
  StepEnterAccountHeaderForm() : super();

  @override
  _StepEnterAccountHeaderFormState createState() => _StepEnterAccountHeaderFormState();
}

class _StepEnterAccountHeaderFormState extends State<StepEnterAccountHeaderForm> {
  //Stepper steps

  _StepEnterAccountHeaderFormState();

  Widget deleteButton(BuildContext context) {
    final stepEnterAccountHeaderBloc = BlocProvider.of<StepEnterAccountHeaderBloc>(context);
    final stepEnterAccountBloc = BlocProvider.of<StepEnterAccountBloc>(context);
    var storage = Storage();
    StepDataEnterAccount stepDataEnterAccount = storage.getStorageData(0) as StepDataEnterAccount;
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
            stepEnterAccountBloc.add(AccountDelete(networkType: stepDataEnterAccount.networkType));

            //update selected node in storage
            //storage.selectedNode = storage.getDefaultNode();

            StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0) as StepDataEnterAccount;
            storageStepEnterAccount.accountID = '';

            //save
            storage.save();

            //change state on step header
            stepEnterAccountHeaderBloc.add(WithoutAccountIDEvent(
                networkType: storageStepEnterAccount.networkType));
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

  String truncateAccountName(String accountName, int length)
  {
    if (length < 0)
      return accountName;
    //we check with length + 3 because of three dots
    if (accountName.length > length + 3)
        return accountName.substring(0, length) + "...";
    return accountName;
  }

  //different text when state is in outside call
  String selectNetworkText(StepEnterAccountHeaderState state){
    if (state is WithAccountIDOutsideCallState) {
      String url = (NETWORK_CHAINS[NetworkType.CUSTOM] != null && NETWORK_CHAINS[NetworkType.CUSTOM]![NETWORK_CHAIN_NAME] != null) ?
                    NETWORK_CHAINS[NetworkType.CUSTOM]![NETWORK_CHAIN_NAME] as String
                    : '';
      String withoutHTTP = url
                          .replaceAll("https://", "")
                          .replaceAll("http://", "");
      return truncateNetwork(
          withoutHTTP, 18);
    }
    else
      return truncateNetwork(state.networkType != null? Storage().nodeSet.networkTypeToString(state.networkType): "", 5);
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
                    Container(child: CustomChip(titles: [selectNetworkText(state)]), margin: EdgeInsets.only(left: 3.0))
                  ]),
                  Row(children: <Widget>[
                    Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                                if (state is WithAccountIDState)
                                  if(state.accountID != '')
                                    Container(child: CustomChip(titles: [truncateAccountName(state.accountID, 20)]), margin: EdgeInsets.only(left: 3.0)),
                                if (state is WithAccountIDOutsideCallState)
                                  if(state.accountID != '')
                                    Container(child: CustomChip(titles: [truncateAccountName(state.accountID, 20)]), margin: EdgeInsets.only(left: 3.0)),
                            ]),
                    if (state is WithAccountIDState)
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
