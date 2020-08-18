import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestationHeader/stepAttestationHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:eosio_passid_mobile_app/utils/storage.dart';


class StepAttestationHeaderBloc extends Bloc<StepAttestationHeaderEvent, StepAttestationHeaderState> {
  @override
  StepAttestationHeaderState get initialState {
    Storage storage = Storage();
    StepDataAttestation stepDataAttestation = storage.getStorageData(2);
    print( stepDataAttestation.requestType);
    return AttestationHeaderWithDataState(
        requestType: stepDataAttestation.requestType);
  }

  @override
  Stream<StepAttestationHeaderState> mapEventToState(
      StepAttestationHeaderEvent event) async* {
    if (event is AttestationHeaderWithDataEvent) {
      yield AttestationHeaderWithDataState(requestType: event.requestType);
    }
  }
}