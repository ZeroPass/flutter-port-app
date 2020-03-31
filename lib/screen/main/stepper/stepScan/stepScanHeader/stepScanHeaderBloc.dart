import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScanHeader/stepScanHeader.dart';
import 'package:bloc/bloc.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'dart:math';

import 'package:eosio_passid_mobile_app/utils/storage.dart';


class StepScanHeaderBloc extends Bloc<StepScanHeaderEvent, StepScanHeaderState> {
  //final int maxSteps;
  StepScanHeaderBloc();


  var validatorText = '';

  @override
  StepScanHeaderState get initialState => WithoutDataState();

  @override
  void onError(Object error, StackTrace stacktrace) {
    // TODO: implement onError
    print("hey, there is an error");
    print(error);
    super.onError(error, stacktrace);
  }

  @override
  void onTransition(Transition<StepScanHeaderEvent, StepScanHeaderState> transition) {
    super.onTransition(transition);
  }


  @override
  Stream<StepScanHeaderState> mapEventToState( StepScanHeaderEvent event) async* {

    if (event is WithDataEvent) {
      yield WithDataState(documentID:  event.documentID, birth: event.birth, validUntil: event.validUntil);
    } else if (event is NoDataEvent) {
      yield WithoutDataState();
    }
    else {
      yield WithoutDataState();
    }
  }

  @override
  Stream<StepScanHeaderState> transformStates(Stream<StepScanHeaderState> states) {
    // TODO: implement transformStates
    return super.transformStates(states);
  }
}
