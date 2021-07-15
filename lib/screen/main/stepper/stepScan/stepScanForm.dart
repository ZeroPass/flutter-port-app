import 'package:eosio_port_mobile_app/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:eosio_port_mobile_app/screen/main/stepper/stepScan/stepScan.dart";
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import "package:eosio_port_mobile_app/screen/main/stepper/stepper.dart";
import 'package:flutter/cupertino.dart';
import 'package:eosio_port_mobile_app/screen/customDatePicker.dart';
import 'package:eosio_port_mobile_app/screen/theme.dart';

class StepScanForm extends StatefulWidget {
  StepScanForm() : super();

  @override
  _StepScanFormState createState() => _StepScanFormState();
}

class _StepScanFormState extends State<StepScanForm> {
  late TextEditingController _passportIdTextController;
  late TextEditingController _birthTextController;
  late TextEditingController _validUntilTextController;
  late bool _allowExpiredPassport;

  _StepScanFormState() {
    _passportIdTextController = TextEditingController();
    _birthTextController = TextEditingController();
    _validUntilTextController = TextEditingController();
    _allowExpiredPassport = false;
  }

  //update fields in account form
  void updateFields() {
    var storage = Storage();
    StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
    _passportIdTextController.text =
        storageStepScan.isValidDocumentID() ? storageStepScan.getDocumentID() : "";
    _birthTextController.text = storageStepScan.isValidBirth()
        ? CustomDatePicker.formatDate(storageStepScan.getBirth())
        : "";
    _validUntilTextController.text = storageStepScan.isValidValidUntil()
        ? CustomDatePicker.formatDate(storageStepScan.getValidUntil())
        : "";
  }

  //clear fields in account form
  void emptyFields() {
    _passportIdTextController.text = '';
    _birthTextController.text = '';
    _validUntilTextController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    Storage storage = Storage();
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final stepScanBloc = BlocProvider.of<StepScanBloc>(context);
    final stepperBloc = BlocProvider.of<StepperBloc>(context);

    return BlocBuilder(
      bloc: stepScanBloc,
      builder: (BuildContext context, StepScanState state) {

        if (state is StateScan) emptyFields();
        updateFields();

        return Form(
            key: _formKey,
            autovalidate: true,
            child: Column(children: <Widget>[
              SelectableText(
                'This data is only used to establish secure communication between your device and passport.',
                style: TextStyle(
                    color: AndroidThemeST().getValues().themeValues["STEPPER"]
                        ["STEP_SCAN"]["COLOR_TEXT"]),
              ),

              TextFormField(
                controller: _passportIdTextController,
                decoration: InputDecoration(
                  labelText: 'Passport No.',
                ),
                //autofocus: true,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter(RegExp(r'[A-Z0-9]+')),
                  LengthLimitingTextInputFormatter(14)
                ],
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.characters,
                validator: (value) =>value != null?RegExp(r"^[a-zA-Z0-9]*$").hasMatch(value)
                    ? null : "Special characters not allowed."
                    : null,

                onChanged: (value) {
                  if (_passportIdTextController.text != value.toUpperCase())
                    _passportIdTextController.value = _passportIdTextController
                        .value
                        .copyWith(text: value.toUpperCase());

                  //save to storage
                  StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
                  storageStepScan.documentID = _passportIdTextController.text;
                  storage.save();

                  stepperBloc.liveModifyHeader(1, context);
                },
              ),
              SizedBox(height: 17),
              CustomDatePicker(
                text: "Date of Birth",
                firstDate: DateTime(DateTime.now().year - 90),
                lastDate: DateTime(DateTime.now().year - 10, DateTime.now().month,
                    DateTime.now().day),
                callbackOnDatePicked: /*callback*/ (selectedDate) {
                  //save to storage
                  StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
                  storageStepScan.birth = selectedDate;
                  //save storage
                  storage.save();

                  //update header
                  stepperBloc.liveModifyHeader(1, context);
                },
                callbackOnUpdate: /*callback*/ (String value) {
                  StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
                  if (value == "")
                    storageStepScan.birth = null;
                  else {
                    try {
                      storageStepScan.birth =
                          CustomDatePicker.parseDateFormated(value);
                    } catch (e) {
                      print("Converting throws error.");
                    }
                  }
                  //save storage
                  storage.save();

                  //update header
                  stepperBloc.liveModifyHeader(1, context);
                },
                textEditingController: _birthTextController,
              ),
              SizedBox(height: 17),//temp raised from 17
              CustomDatePicker(
                    text:"Date of Expiry",
                    firstDate:  (this._allowExpiredPassport)
                    ? DateTime(DateTime.now().year - 90)
                    : DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1),
                  lastDate: DateTime(DateTime.now().year + 10),
                  callbackOnDatePicked: /*callback*/ (selectedDate) {
                  //save to storage
                  StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
                  storageStepScan.validUntil = selectedDate;
                  //save storage
                  storage.save();

                  //update header
                  stepperBloc.liveModifyHeader(1, context);
                  },
                  callbackOnUpdate:  /*callback*/ (String value) {
                  StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
                  if (value == "")
                    storageStepScan.validUntil = null;
                  else {
                    try {
                      storageStepScan.validUntil =
                          CustomDatePicker.parseDateFormated(value);
                    } catch (e) {
                      print("Converting throws error.");
                    }
                  }
                  //save storage
                  storage.save();

                  //update header
                  stepperBloc.liveModifyHeader(1, context);
                  },
                  textEditingController: _validUntilTextController
                  ),

              Row( mainAxisAlignment: MainAxisAlignment.end, children:[
                SelectableText(
                    'Allow expired passports',
                    style: TextStyle(
                        fontSize: AndroidThemeST().getValues().themeValues["STEPPER"]
                        ["STEP_SCAN"]["SIZE_SMALLER_TEXT"],
                        color: AndroidThemeST().getValues().themeValues["STEPPER"]
                        ["STEP_SCAN"]["COLOR_TEXT"])),
                  PlatformSwitch(
                    value: this._allowExpiredPassport,
                    onChanged: (bool value) => setState(() => this._allowExpiredPassport = value),
                )
              ])
            ]));
      },
    );
  }
}
