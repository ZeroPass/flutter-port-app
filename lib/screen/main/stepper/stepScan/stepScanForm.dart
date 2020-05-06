import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScan.dart";
import "package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart";
import 'package:flutter/cupertino.dart';
import 'package:eosio_passid_mobile_app/screen/customDatePicker.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';

class StepScanForm extends StatefulWidget {
  StepScanForm({Key key}) : super(key: key);

  @override
  _StepScanFormState createState() => _StepScanFormState();
}

class _StepScanFormState extends State<StepScanForm> {
  TextEditingController _passportIdTextController = TextEditingController();
  TextEditingController _birthTextController = TextEditingController();
  TextEditingController _validUntilTextController = TextEditingController();
  //Stepper steps

  _StepScanFormState({Key key}) {
    _passportIdTextController = TextEditingController();
    _birthTextController = TextEditingController();
    _validUntilTextController = TextEditingController();
  }

  //update fields in account form
  void updateFields() {
    var storage = Storage();
    StepDataScan storageStepScan = storage.getStorageData(1);
    _passportIdTextController.text = storageStepScan.documentID != null?
        storageStepScan.documentID : "";
    _birthTextController.text = storageStepScan.birth != null?
        CustomDatePicker.formatDate(storageStepScan.birth) : "";
    _validUntilTextController.text = storageStepScan.validUntil != null?
        CustomDatePicker.formatDate(storageStepScan.validUntil) : "";
  }

  //clear fields in account form
  void emptyFields() {
    print("fileds empty process");
    _passportIdTextController.text = '';
    _birthTextController.text = '';
    _validUntilTextController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    Storage storage = Storage();
    StepDataScan storageStepScan = storage.getStorageData(1);

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final stepScanBloc = BlocProvider.of<StepScanBloc>(context);
    final stepperBloc = BlocProvider.of<StepperBloc>(context);

    return BlocBuilder(
      bloc: stepScanBloc,
      builder: (BuildContext context, StepScanState state) {
        updateFields();
        if (state is StateScan) emptyFields();

        return Form(
            key: _formKey,
            autovalidate: true,
            child: Column(children: <Widget>[
              //const AndroidThemeST().getValues().themeValues["STEPPER"]["STEP_SCAN"]["COLOR_TEXT"]
              Text(
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
                validator: (value) => RegExp(r"^[a-zA-Z0-9]*$").hasMatch(value)
                    ? null
                    : "Special characters not allowed.",

                onChanged: (value) {
                  if (_passportIdTextController.text != value.toUpperCase())
                    _passportIdTextController.value = _passportIdTextController
                        .value
                        .copyWith(text: value.toUpperCase());

                  //save to storage
                  storageStepScan.documentID = _passportIdTextController.text;
                  storage.save();

                  stepperBloc.liveModifyHeader(1, context);
                },
              ),
              SizedBox(height: 17),
              CustomDatePicker(
                  "Date of Birth",
                  DateTime(1930),
                  DateTime(DateTime.now().year - 10, DateTime.now().month,
                      DateTime.now().day),
                  /*callback*/ (selectedDate) {
                    //save to storage
                    storageStepScan.birth = selectedDate;
                    //save storage
                    storage.save();

                    //update header
                    stepperBloc.liveModifyHeader(1, context);
                  },
                  /*callback*/ (String value) {
                    if (value == null || value == "")
                      storageStepScan.birth = null;
                    else
                      {
                        try {
                          storageStepScan.birth = CustomDatePicker.parseDateFormated(value);
                        }
                        catch(e){
                          print("Converting throws error.");
                        }
                      }
                      //save storage
                    storage.save();

                    //update header
                    stepperBloc.liveModifyHeader(1, context);
              },
                _birthTextController,
              ),
              SizedBox(height: 17),
              CustomDatePicker(
                  "Date of Expiry",
                  DateTime(DateTime.now().year, DateTime.now().month,
                      DateTime.now().day + 1),
                  DateTime(2030),
                  /*callback*/ (selectedDate) {
                //save to storage
                storageStepScan.validUntil = selectedDate;
                //save storage
                storage.save();

                //update header
                stepperBloc.liveModifyHeader(1, context);
              },
                  /*callback*/ (String value) {
                  if (value == null || value == "")
                    storageStepScan.validUntil = null;
                  else
                  {
                    try {
                      storageStepScan.validUntil = CustomDatePicker.parseDateFormated(value);
                    }
                    catch(e){
                      print("Converting throws error.");
                    }
                  }
                  //save storage
                  storage.save();

                  //update header
                  stepperBloc.liveModifyHeader(1, context);
                },
                _validUntilTextController)
            ]));
      },
    );
  }
}
