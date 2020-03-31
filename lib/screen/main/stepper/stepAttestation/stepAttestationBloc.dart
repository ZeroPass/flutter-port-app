import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:bloc/bloc.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import 'package:eosio_passid_mobile_app/utils/storage.dart';

class StepDataAttestation extends StepData{
  String _temp;

  StepDataAttestation(){
    _temp = null;
  }
}

class StepAttestationBloc extends Bloc<StepAttestationEvent, StepAttestationState> {
  StepAttestationBloc();

  @override
  StepAttestationState get initialState => NotAllDataInStorage();

  @override
  Stream<StepAttestationState> mapEventToState( StepAttestationEvent event) async* {
    print("Step attestation bloc mapEventToState");
    print(state.toString());
    if (event is AllDataInStorageEvent) {
      print("With data");
      yield AllDataInStorage(temp: "");
    } else if (event is NotAllDataInStorageEvent) {
      print("StepCancelled");
      yield NotAllDataInStorage();
    }
    else {
      print ("else event");
      yield NotAllDataInStorage();
    }
  }
}
