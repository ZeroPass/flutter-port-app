import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:bloc/bloc.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'dart:math';

import 'package:eosio_passid_mobile_app/utils/storage.dart';


class StepEnterAccountHeaderBloc extends Bloc<StepEnterAccountHeaderEvent, StepEnterAccountHeaderState> {
  //final int maxSteps;
  StepEnterAccountHeaderBloc();


  var validatorText = '';

  @override
  StepEnterAccountHeaderState get initialState => WithoutAccountIDState(network: Storage().getSelectedNode(), server: Storage().getStorageServer());

  @override
  void onError(Object error, StackTrace stacktrace) {
    // TODO: implement onError
    print("hey, there is an error");
    print(error);
    super.onError(error, stacktrace);
  }

  @override
  void onTransition(Transition<StepEnterAccountHeaderEvent, StepEnterAccountHeaderState> transition) {
    super.onTransition(transition);
  }

  /*@override
  void onEvent(StepEnterAccountHeaderEvent event) {
    print("in event function");
    print(event);
    this.toSet();
    super.onEvent(event);
  }*/
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

    if (event is WithAccountIDEvent) {
        yield WithAccountIDState(network: event.network, server: event.server, accountID: event.accountID);
    } else if (event is WithoutAccountIDEvent) {
      yield WithoutAccountIDState(network: event.network, server: event.server);
    }
    else {
      yield WithoutAccountIDState(network: event.network, server: event.server);
    }
  }

  @override
  Stream<StepEnterAccountHeaderState> transformStates(Stream<StepEnterAccountHeaderState> states) {
    // TODO: implement transformStates
    return super.transformStates(states);
  }
}
