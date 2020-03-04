import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:bloc/bloc.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import 'package:eosio_passid_mobile_app/utils/storage.dart';

class StepDataScan extends StepData{
  String _accountID;

  StepDataScan(){
    _accountID = '';
  }

  String get accountID => _accountID;

  set accountID(String value) {
    _accountID = value;
    //data is written(to check when we need to read from database)
    this.hasData = true;
    //activate the button
    this.isUnlocked = true;

    }
}

class StepScanBloc extends Bloc<StepScanEvent, StepScanState> {
  //final int maxSteps;
  StepScanBloc(/*{@required this.maxSteps}*/);


  var validatorText = '';

  @override
  StepScanState get initialState => EmptyState();

  //separate function because of async function
  bool validatorFunction (String value, var context) {
    final stepScanBloc = BlocProvider.of<StepScanBloc>(context);


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
    print("Step enter account bloc: mapEventToState");
    if (event is AccountConfirmation) {
      print("AccountConfirmation");
      yield FullState();
    } else if (event is AccountDelete) {
      print("StepCancelled");
      yield EmptyState();
    }
    else {
      print ("else event");
      yield EmptyState();
    }
  }
}
