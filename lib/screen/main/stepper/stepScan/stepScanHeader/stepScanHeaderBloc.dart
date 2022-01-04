import 'package:eosio_port_mobile_app/screen/main/stepper/stepScan/stepScanHeader/stepScanHeader.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:eosio_port_mobile_app/utils/storage.dart';


class StepScanHeaderBloc extends Bloc<StepScanHeaderEvent, StepScanHeaderState> {
  //final int maxSteps;
  StepScanHeaderBloc() : super(WithoutDataState()) {
    on<WithDataEvent>((event, emit) => emit (WithDataState(documentID:  event.documentID, birth: event.birth, validUntil: event.validUntil)));
    on<NoDataEvent>((event, emit) => emit (WithoutDataState()));

    updateDataOnUI();
  }

  //check if there is any data stored
  void updateDataOnUI(){
    //check updated data
    Storage storage = Storage();
    storage.load(callback: (isAlreadyUpdated, isValid,  {String? exc}){
      if (isAlreadyUpdated == true || isValid == true){
        StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
        if (storageStepScan.isValidDocumentID() || storageStepScan.isValidBirth() || storageStepScan.isValidValidUntil())
        this.add(WithDataEvent(documentID: storageStepScan.isValidDocumentID() ? storageStepScan.getDocumentID() : null,
            birth: storageStepScan.isValidBirth() ? storageStepScan.getBirth() : null,
            validUntil: storageStepScan.isValidValidUntil() ? storageStepScan.getValidUntil() : null));
      }
    });
  }

  //@override
  //StepScanHeaderState get initialState => WithoutDataState();

  @override
  void onError(Object error, StackTrace stacktrace) {
    super.onError(error, stacktrace);
  }

  @override
  void onTransition(Transition<StepScanHeaderEvent, StepScanHeaderState> transition) {
    super.onTransition(transition);
  }

  /*@override
  Stream<StepScanHeaderState> mapEventToState( StepScanHeaderEvent event) async* {

    if (event is WithDataEvent) {
      yield WithDataState(documentID:  event.documentID, birth: event.birth, validUntil: event.validUntil);
    } else if (event is NoDataEvent) {
      yield WithoutDataState();
    }
    else {
      yield WithoutDataState();
    }
  }*/
}
