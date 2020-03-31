import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScan.dart";
import "package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart";
import 'package:flutter/cupertino.dart';
import 'package:eosio_passid_mobile_app/screen/customDatePicker.dart';
import 'package:eosio_passid_mobile_app/screen/customAlertDialog.dart';

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

  _StepScanFormState({Key key}){
    _passportIdTextController = TextEditingController();
    _birthTextController = TextEditingController();
    _validUntilTextController = TextEditingController();
  }

  //update fields in account form
  void updateFields() {
    var storage = Storage();
    StepDataScan storageStepScan = storage.getStorageData(1);
    _passportIdTextController.text = storageStepScan.documentID;
    _birthTextController.text = CustomDatePicker.customizeDate(storageStepScan.birth);
    _validUntilTextController.text = CustomDatePicker.customizeDate(storageStepScan.validUntil);

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

        if (state is StateScan) emptyFields();
        if (state is FullState) updateFields();

        return Form(
            key: _formKey,
            autovalidate: true,
            child: Column(children: <Widget>[
              TextFormField(
                controller: _passportIdTextController,
                decoration: InputDecoration(
                  labelText: 'Passport No.',
                ),
                //autofocus: true,
                validator: (value) => RegExp(r"^[a-zA-Z0-9]*$").hasMatch(value) ? null : "Special characters not allowed.",

                onChanged: (value) {
                  print("value changed");
                  if (_passportIdTextController.text != value.toUpperCase())
                    _passportIdTextController.value = _passportIdTextController.value
                        .copyWith(text: value.toUpperCase());

                  //save to storage
                  storageStepScan.documentID = _passportIdTextController.text;

                  stepperBloc.liveModifyHeader(1, context);
                },
              ),
              SizedBox(height: 17),
              CustomDatePicker("Date of Birth",
                      DateTime(1950),
                      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                      /*callback*/(selectedDate){
                        /*if (DateTime.now().difference(selectedDate).inDays < 0 ) {
                          _birthTextController.text = null;
                          CustomAlertDialog(context, "Date of birth cannot be in the future.");
                        }*/
                      //save to storage
                      storageStepScan.birth = selectedDate;
                      //update header
                      stepperBloc.liveModifyHeader(1, context);
                      },
                  _birthTextController),
              SizedBox(height: 17),
              CustomDatePicker("Date of Expiration",
                  DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                  DateTime(2100),
                      /*callback*/(selectedDate){
                      /*if (DateTime.now().difference(selectedDate).inDays > 0 ) {
                        _birthTextController.text = null;
                        CustomAlertDialog(context, "Date of Expiration should not be in the past.");
                      }*/
                      //save to storage
                      storageStepScan.validUntil = selectedDate;
                      //update header
                      stepperBloc.liveModifyHeader(1, context);
                      },
                      _validUntilTextController)
            ]));
      },
    );
  }
}
