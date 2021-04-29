import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestationHeader/stepAttestationHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:bloc/bloc.dart';
import 'package:eosio_passid_mobile_app/screen/requestType.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:eosio_passid_mobile_app/utils/storage.dart';


class StepAttestationHeaderBloc extends Bloc<StepAttestationHeaderEvent, StepAttestationHeaderState> {

  StepAttestationHeaderBloc({RequestType requestType}): super(AttestationHeaderWithDataState(requestType: requestType)){
    updateDataOnUI();
  }

  //check if there is any data stored
  void updateDataOnUI(){
    //check updated data
    Storage storage = Storage();
    storage.load(callback: (isAlreadyUpdated, isValid,  {String exc}){
      if (isAlreadyUpdated == true || isValid == true){
        StepDataAttestation storageAttestation = storage.getStorageData(2);
          this.add(AttestationHeaderWithDataEvent(requestType: storageAttestation.requestType));
      }
    });
  }

  /*@override
  StepAttestationHeaderState get initialState {
    Storage storage = Storage();
    StepDataAttestation stepDataAttestation = storage.getStorageData(2);
    return AttestationHeaderWithDataState(
        requestType: stepDataAttestation.requestType);
  }*/

  @override
  Stream<StepAttestationHeaderState> mapEventToState(
      StepAttestationHeaderEvent event) async* {
    if (event is AttestationHeaderWithDataEvent) {
      yield AttestationHeaderWithDataState(requestType: event.requestType);
    }
  }
}