import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:bloc/bloc.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import 'package:eosio_passid_mobile_app/utils/storage.dart';

class StepDataScan extends StepData{
  String _documentID;
  DateTime _validUntil;
  DateTime _birth;

  StepDataScan(){
    _documentID = null;
    _validUntil = null;
    _birth = null;
  }

  String get documentID => _documentID;

  set documentID(String value) {
    _documentID = value;
  }

  DateTime get validUntil => _validUntil;

  set validUntil(DateTime value) {
    _validUntil = value;
  }

  DateTime get birth => _birth;

  set birth(DateTime value) {
    _birth = value;
  }
}

class StepScanBloc extends Bloc<StepScanEvent, StepScanState> {
  //final int maxSteps;
  StepScanBloc(/*{@required this.maxSteps}*/);


  var validatorText = '';

  @override
  StepScanState get initialState => StateScan();

  //separate function because of async function
  bool validatorFunction (String value, var context) {
    //next button locked
    var storage = Storage();
    StepDataScan storageStepScan = storage.getStorageData(1);
    //Default value is false. If string passes all conditions then we change it on true
    storageStepScan.isUnlocked = false;

    validatorText = '';
    return false;
    }

  Future<bool> accountExists (String accountName, int delaySec) async{
    //TODO: implement this function
    Future.delayed(Duration(seconds: delaySec), (){});
    return true;
  }

  @override
  Stream<StepScanState> mapEventToState( StepScanEvent event) async* {
    print("Step Scan bloc mapEventToState");
    print(state.toString());
    if (event is WithDataScan) {
      print("With data");
      yield FullState(documentID: event.documentID, birth: event.birth, validUntil: event.validUntil);
    } else if (event is NoDataScan) {
      print("StepCancelled");
      yield StateScan();
    }
    else {
      print ("else event");
      yield StateScan();
    }
  }
}
