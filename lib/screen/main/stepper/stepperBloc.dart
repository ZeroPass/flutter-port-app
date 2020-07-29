import 'package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScanHeader/stepScanHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestationHeader/stepAttestationHeader.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';


//every step should extend this class to handle if step is filled correctly
//we are going to use this class to save data for later use
abstract class StepData{
  bool _isUnlocked;

  StepData(){
    _isUnlocked = false;
    _hasData = false;
  }

  bool get isUnlocked => _isUnlocked;

  set isUnlocked(bool value) {
    _isUnlocked = value;
  }

  bool _hasData;

  bool get hasData => _hasData;

  set hasData(bool value) {
    _hasData = value;
  }
}

class StepperBloc extends Bloc<StepperEvent, StepperState> {
  final int maxSteps;

  StepperBloc({@required this.maxSteps}){}

  @override
  StepperState get initialState => StepperState(step: 0, maxSteps: maxSteps);

  @override
  void onTransition(Transition<StepperEvent, StepperState> transition) {
    super.onTransition(transition);
    print(transition);
  }

  bool liveModifyHeader (int step, var context) {
    var storage = Storage();
    switch (step) {
      case 0:
        {
          //step 1
          final stepEnterAccountHeaderBloc = BlocProvider.of<StepEnterAccountHeaderBloc>(context);
          StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0);
          //show data on header if there is valid value
          if (storageStepEnterAccount.accountID == null || storageStepEnterAccount.accountID == "")
            stepEnterAccountHeaderBloc.add(WithoutAccountIDEvent(network: storage.getSelectedNode(), server: storage.getStorageServer()));
          else {
            stepEnterAccountHeaderBloc.add(WithAccountIDEvent(
                accountID: storageStepEnterAccount.accountID,
                server: storage.getStorageServer(),
                network: storage.getSelectedNode()));
          }
          }
        break;

      case 1:
        {
          final stepScanHeaderBloc = BlocProvider.of<StepScanHeaderBloc>(context);
          StepDataScan storageStepScan = storage.getStorageData(1);
          //show data on header if there is valid value
          if (storageStepScan.documentID == null && storageStepScan.birth == null && storageStepScan.validUntil == null)
            stepScanHeaderBloc.add(NoDataEvent());
          else {
            stepScanHeaderBloc.add(WithDataEvent(
                documentID: storageStepScan.documentID,
                birth: storageStepScan.birth,
                validUntil: storageStepScan.validUntil));
          }
          //statements;
        }
        break;

      case 2:
        {
          final stepAttestationHeaderBloc = BlocProvider.of<StepAttestationHeaderBloc>(context);
          StepDataAttestation storageStepAttestation = storage.getStorageData(2);
          stepAttestationHeaderBloc.add(AttestationHeaderWithDataEvent(requestType: storageStepAttestation.requestType));
        }
        break;

      default:
        {
          //statements;
        }
        break;
    }
  }

  @override
  Stream<StepperState> mapEventToState(StepperEvent event) async* {
    if (event is StepTapped) {
      yield state.copyWith(step: event.step, maxSteps: state.maxSteps);
    }
    else if (event is StepCancelled) {
      yield state.copyWith(
          step: state.step - 1 >= 0 ? state.step - 1 : 0,
          maxSteps: state.maxSteps
      );
    }
    else if (event is StepContinue) {
      yield state.copyWith(
          step: state.step + event.stepsJump < this.maxSteps ? state.step + event.stepsJump : 0,
          maxSteps: state.maxSteps
      );
    }
  }
}