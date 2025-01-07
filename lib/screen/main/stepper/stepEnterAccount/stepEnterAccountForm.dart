import 'package:port_mobile_app/constants/constants.dart';
import 'package:port_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:port_mobile_app/utils/structure.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:port_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart";
import "package:port_mobile_app/screen/main/stepper/stepper.dart";
import 'package:flutter/cupertino.dart';
import 'package:port_mobile_app/utils/storage.dart';
import 'package:port_mobile_app/screen/customBottomPicker.dart';
import 'package:port_mobile_app/utils/size.dart';
import 'package:port_mobile_app/screen/theme.dart';

class StepEnterAccountForm extends StatefulWidget {

  @override
  _StepEnterAccountFormState createState() => _StepEnterAccountFormState();
}

class _StepEnterAccountFormState extends State<StepEnterAccountForm> {
  late TextEditingController _accountTextController;
  late Storage _storage;

  _StepEnterAccountFormState() {
    this._accountTextController = TextEditingController();
    this._storage = Storage();
  }

  //update fields in account form
  void updateFields() {
    var storage = Storage();

    if (storage.outsideCall.isOutsideCall)
      _accountTextController.text = storage.outsideCall.getStructV1()!.accountID;
    else {
      StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0) as StepDataEnterAccount;
      _accountTextController.text =
      storageStepEnterAccount.accountID != null ? storageStepEnterAccount
          .accountID : "";
    }
  }

  //clear fields in account form
  void emptyFields() {
    _accountTextController.text = "";
  }

  void selectNetwork(var context, StepEnterAccountState state, var stepEnterAccountBloc) {
    var storage = Storage();
    StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0) as StepDataEnterAccount;
    BottomPickerStructure bps = BottomPickerStructure();
    bps.importNetworkList(storage.nodeSet, storageStepEnterAccount.networkType,
        title: "Select node", message: "Please select the node");
    CustomBottomPickerState cbps = CustomBottomPickerState(structure: bps);
    cbps.showPicker(context,
        //callback function to manage user click action on selection
        (BottomPickerElement returnedStorageNode) {
      //find the node with the same name as returned name
          storage.nodeSet.networks.forEach((key, value) {
            if (key == EnumUtil.fromStringEnum(NetworkType.values, returnedStorageNode.key)) {
              storageStepEnterAccount.networkType =
                  EnumUtil.fromStringEnum(NetworkType.values, returnedStorageNode.key);
              storage.save();

              if (state is FullState) {
                stepEnterAccountBloc.add(AccountConfirmation(
                    accountID: storageStepEnterAccount.accountID,
                    networkType: storageStepEnterAccount.networkType));
              }
              if (state is DeletedState) {
                stepEnterAccountBloc.add(AccountDelete(networkType:  storageStepEnterAccount.networkType));
              }
              final stepperBloc = BlocProvider.of<StepperBloc>(context);
              stepperBloc.liveModifyHeader(0, context);
            }
          });
    });
  }

  //different text when state is in outside call
  String selectNetworkText(StepEnterAccountState state){
    if (state is FullStateOutsideCall) {
      if (NETWORK_CHAINS[NetworkType.CUSTOM] != null && NETWORK_CHAINS[NetworkType.CUSTOM]![NETWORK_CHAIN_NAME] != null)
        return NETWORK_CHAINS[NetworkType.CUSTOM]![NETWORK_CHAIN_NAME] as String;
      else
        throw Exception("StepEnterAccountForm.selectNetworkText; no chain name when state is 'FullStateOutsideCall'");
    }
    else
      return truncateNetwork(Storage().nodeSet.networkTypeToString(state.networkType), 15);
  }

  Widget selectNetworkWithTile(var context,
      StepEnterAccountState state,
      var stepEnterAccountBloc) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Network',
              style: TextStyle(
                  fontSize: AndroidThemeST().getValues().themeValues["TILE_BAR"]
                      ["SIZE_TEXT"]),
            ),
            Text(selectNetworkText(state),
                style: TextStyle(
                    fontSize: AndroidThemeST()
                        .getValues()
                        .themeValues["TILE_BAR"]["SIZE_TEXT"],
                    color: AndroidThemeST().getValues().themeValues["TILE_BAR"]
                        ["COLOR_TEXT"]))
          ]),
      trailing: (!(state is FullStateOutsideCall))?Icon(Icons.expand_more) : null,
      onTap: () {
        //do not allow when state is in the outside call
        if (!(state is FullStateOutsideCall))
          selectNetwork(context, state, stepEnterAccountBloc);
      },
    );
  }

  Widget body(BuildContext context,
      StepEnterAccountState state,
      var stepEnterAccountBloc)
  {
    if (state is DeletedState) emptyFields();
    if (state is FullState || state is FullStateOutsideCall) updateFields();

    final stepperBloc = BlocProvider.of<StepperBloc>(context);
    return Form(
        child: Column(children: <Widget>[
          selectNetworkWithTile(context, state, stepEnterAccountBloc),
          //if (storage.selectedNode.name != "ZeroPass Server")
            TextFormField(
              readOnly: state is FullStateOutsideCall ? true : false,
              controller: _accountTextController,
              decoration: InputDecoration(
                //border: InputBorder.none,
                labelText: 'Account name',
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'\b[a-z1-5.]+')),
                LengthLimitingTextInputFormatter(13)
              ],
              validator: (value) =>
                  stepEnterAccountBloc.validatorFunction(value, context)
                      ? stepEnterAccountBloc.validatorText
                      : null,
              onChanged: (value) async {
                //save to storage
                StepDataEnterAccount storageStepEnterAccount = _storage.getStorageData(0) as StepDataEnterAccount;
                storageStepEnterAccount.accountID = _accountTextController.text.length !=0 ? _accountTextController.text : '';
                //save storage
                _storage.save();

                stepperBloc.liveModifyHeader(0, context);
              },
            ),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    final stepEnterAccountBloc = BlocProvider.of<StepEnterAccountBloc>(context);
    return BlocBuilder(
      bloc: stepEnterAccountBloc,
      builder: (BuildContext context, StepEnterAccountState state) {
        return Container(
            width: CustomSize.getMaxWidth(context, STEPPER_ICON_PADDING),
            child: body(context, state, stepEnterAccountBloc));
      },
    );
  }
}