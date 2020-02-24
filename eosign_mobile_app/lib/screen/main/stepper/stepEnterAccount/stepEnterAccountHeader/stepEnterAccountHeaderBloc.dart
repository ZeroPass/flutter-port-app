import 'package:eosign_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:bloc/bloc.dart';
import 'package:eosign_mobile_app/screen/main/stepper/stepper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import 'package:eosign_mobile_app/utils/storage.dart';


class StepEnterAccountHeaderBloc extends Bloc<StepEnterAccountHeaderEvent, StepEnterAccountHeaderState> {
  //final int maxSteps;
  StepEnterAccountHeaderBloc();


  var validatorText = '';

  @override
  StepEnterAccountHeaderState get initialState => NoAccountIDState();

  @override
  void onTransition(Transition<StepEnterAccountHeaderEvent, StepEnterAccountHeaderState> transition) {
    super.onTransition(transition);
    print(transition);
  }
/*
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
    Future.delayed(Duration(seconds: delaySec), (){});
    return true;
  }*/

  @override
  Stream<StepEnterAccountHeaderState> mapEventToState( StepEnterAccountHeaderEvent event) async* {
    print("Step enter account bloc: mapEventToState");
    if (event is AccountConfirmed) {
      yield AccountIDState(accountID: event.accountID);
    } else if (event is AccountRemoved) {
      yield NoAccountIDState();
    }
    else {
      yield NoAccountIDState();
    }
  }
}
