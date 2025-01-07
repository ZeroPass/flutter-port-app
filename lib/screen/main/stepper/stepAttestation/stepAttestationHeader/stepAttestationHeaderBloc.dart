import 'package:port_mobile_app/screen/main/stepper/stepAttestation/stepAttestationHeader/stepAttestationHeader.dart';
import 'package:port_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:bloc/bloc.dart';
import 'package:port_mobile_app/screen/requestType.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:port_mobile_app/utils/storage.dart';


class StepAttestationHeaderBloc extends Bloc<StepAttestationHeaderEvent, StepAttestationHeaderState> {

  StepAttestationHeaderBloc({required RequestType requestType}): super(AttestationHeaderWithDataState(requestType: requestType)){
    on<AttestationHeaderWithDataEvent>((event, emit) => emit (AttestationHeaderWithDataState(requestType: event.requestType)));
    on<AttestationHeaderWithDataOutsideCallEvent>((event, emit) => emit (AttestationHeaderWithDataOutsideCallState(requestType: event.requestType)));

    updateDataOnUI();
  }

  //check if there is any data stored
  void updateDataOnUI(){
    //check updated data
    Storage storage = Storage();
    storage.load(callback: (isAlreadyUpdated, isValid,  {String? exc}){
      if (isAlreadyUpdated == true || isValid == true){
        StepDataAttestation storageAttestation = storage.getStorageData(2) as StepDataAttestation;

        if (storage.outsideCall.isOutsideCall)
          this.add(AttestationHeaderWithDataOutsideCallEvent(requestType: storage.outsideCall.getStructV1()!.requestType));
        else
          this.add(AttestationHeaderWithDataEvent(requestType: storageAttestation.requestType));
      }
    });
  }

  /*@override
  Stream<StepAttestationHeaderState> mapEventToState(
      StepAttestationHeaderEvent event) async* {
    if (event is AttestationHeaderWithDataEvent) {
      yield AttestationHeaderWithDataState(requestType: event.requestType);
    }
    else if (event is AttestationHeaderWithDataOutsideCallEvent) {
      yield AttestationHeaderWithDataOutsideCallState(requestType: event.requestType);
    }
  }*/
}