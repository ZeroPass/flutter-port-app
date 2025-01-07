import 'package:port_mobile_app/screen/main/stepper/stepper.dart';
import 'package:port_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:port_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:port_mobile_app/screen/main/stepper/stepScan/stepScanHeader/stepScanHeader.dart';
import 'package:port_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:port_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:port_mobile_app/screen/main/stepper/stepAttestation/stepAttestationHeader/stepAttestationHeader.dart';
import 'package:port_mobile_app/screen/main/stepper/stepReview/stepReviewHeader/stepReviewHeader.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:port_mobile_app/utils/storage.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:logging/logging.dart';


//every step should extend this class to handle if step is filled correctly
//we are going to use this class to save data for later use
abstract class StepData{
  late bool _isUnlocked;
  late bool _hasData;

  StepData(){
    _isUnlocked = false;
    _hasData = false;
  }

  bool get isUnlocked => _isUnlocked;

  set isUnlocked(bool value) {
    _isUnlocked = value;
  }

  bool get hasData => _hasData;

  set hasData(bool value) {
    _hasData = value;
  }
}

class StepperBloc extends Bloc<StepperEvent, StepperState> {
  final int maxSteps;
  late bool isReviewLocked;
  final _log = Logger('passid.StepperBloc');

  //StepperBloc():super();

  StepperBloc({required this.maxSteps}) :
        super( Storage().outsideCall.isOutsideCall ?
              StepperState(step: 1, previousStep: 0, maxSteps: maxSteps) :
              StepperState(step: 0, previousStep: 0, maxSteps: maxSteps)){

    on<StepTapped>((event, emit) {
        if (event.step < state.maxSteps-1) // do not allow access to last step
          emit (StepperState(step: event.step, previousStep: state.step, maxSteps: state.maxSteps));
      }
    );

    on<StepRunByFlow>((event, emit) => emit(StepperState(step: event.step, previousStep: state.step, maxSteps: state.maxSteps)));
    on<StepAfterQR>((event, emit) => emit(StepperState(step: 1, previousStep: state.step, maxSteps: state.maxSteps)));
    on<StepCancelled>((event, emit) => emit(StepperState(step: state.step - 1 >= 0 ? state.step - 1 : 0, previousStep: state.step, maxSteps: state.maxSteps)));
    on<StepContinue>((event, emit) {
      if (state.step + event.stepsJump < this.maxSteps) // do not allow access to last step
        emit(StepperState(
          step: state.step + event.stepsJump < this.maxSteps ? state.step + event.stepsJump : 0,
          previousStep: state.step,
          maxSteps: state.maxSteps
        ));
    });
    on<StepBackToPrevious>((event, emit) {// do not allow access to last step
        if (state.step == state.maxSteps -1) //jump only when you are on last step
          emit(StepperState(
          step: state.previousStep,
          previousStep: state.previousStep,
          maxSteps: state.maxSteps
      ));
    });


    this.isReviewLocked = true;
  }

  //@override
  //StepperState get initialState => StepperState(step: 0, maxSteps: maxSteps);



  bool liveModifyHeader (int step, var context, {bool dataInStep = false}) {
    var storage = Storage();
    switch (step) {
      case 0:
        {
          //step 1
          final stepEnterAccountHeaderBloc = BlocProvider.of<StepEnterAccountHeaderBloc>(context);
          StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0) as StepDataEnterAccount;
          //show data on header if there is valid value
          if (storageStepEnterAccount.accountID == null || storageStepEnterAccount.accountID == "")
            stepEnterAccountHeaderBloc.add(WithoutAccountIDEvent(networkType: storageStepEnterAccount.networkType));
          else {
            stepEnterAccountHeaderBloc.add(WithAccountIDEvent(
                accountID: storageStepEnterAccount.accountID,
                networkType: storageStepEnterAccount.networkType));
          }
          }
        break;

      case 1:
        {
          final stepScanHeaderBloc = BlocProvider.of<StepScanHeaderBloc>(context);
          StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
          //show data on header if there is valid value
          if (storageStepScan.isValidDocumentID() == false &&
              storageStepScan.isValidBirth() == false &&
              storageStepScan.isValidValidUntil() == false)
            stepScanHeaderBloc.add(NoDataEvent());
          else {
            stepScanHeaderBloc.add(WithDataEvent(
                documentID: storageStepScan.isValidDocumentID() ? storageStepScan.getDocumentID(): null,
                birth: storageStepScan.isValidBirth() ? storageStepScan.getBirth(): null,
                validUntil: storageStepScan.isValidValidUntil() ? storageStepScan.getValidUntil(): null));
          }
        }
        break;

      case 2:
        {
          final stepAttestationHeaderBloc = BlocProvider.of<StepAttestationHeaderBloc>(context);
          StepDataAttestation storageStepAttestation = storage.getStorageData(2) as StepDataAttestation;
          stepAttestationHeaderBloc.add(AttestationHeaderWithDataEvent(requestType: storageStepAttestation.requestType));
        }
        break;

      case 3:
        {
          final stepReviewHeaderBloc = BlocProvider.of<StepReviewHeaderBloc>(context);
          if (dataInStep)
            stepReviewHeaderBloc.add(StepReviewHeaderWithDataEvent());
          else
            stepReviewHeaderBloc.add(StepReviewHeaderWithoutDataEvent());
        }
        break;

      default:
        {
          //statements;
        }
        break;
    }
    return true;
  }


  /*@override
  Stream<StepperState> mapEventToState(StepperEvent event) async* {
    _log.log(Level.INFO, "Changing the state of stepper {${event.toString()}");
    print("Stepper bloc mapEventToState");
    if (event is StepTapped) {
      if (event.step < state.maxSteps-1) // do not allow access to last step
        yield state.copyWith(step: event.step, previousStep: state.step, maxSteps: state.maxSteps);
    }
    else if (event is StepRunByFlow) {
        yield state.copyWith(step: event.step, previousStep: state.step, maxSteps: state.maxSteps);
    }
    else if (event is StepAfterQR){
      yield state.copyWith(step: 1, previousStep: state.step, maxSteps: state.maxSteps);
    }
    else if (event is StepCancelled) {
      yield state.copyWith(
          step: state.step - 1 >= 0 ? state.step - 1 : 0,
          previousStep: state.step,
          maxSteps: state.maxSteps
      );
    }
    else if (event is StepContinue) {
      if (state.step + event.stepsJump < this.maxSteps) // do not allow access to last step
        yield state.copyWith(
            step: state.step + event.stepsJump < this.maxSteps ? state.step +
                event.stepsJump : 0,
            previousStep: state.step,
            maxSteps: state.maxSteps
        );
    }
    else if (event is StepBackToPrevious) {
      if (state.step == state.maxSteps -1) //jump only when you are on last step
        yield state.copyWith(
            step: state.previousStep,
            previousStep: state.previousStep,
            maxSteps: state.maxSteps
      );
    }
  }*/
}