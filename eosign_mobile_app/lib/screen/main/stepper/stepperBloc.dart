import 'package:eosign_mobile_app/screen/main/stepper/stepper.dart';
import 'package:eosign_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:eosign_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:eosign_mobile_app/utils/storage.dart';


//every step should extend this class to handel if step is correctly filled
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

  void modifyBody(int previousStep, int nextStep){

  }

  bool modifyHeader (int previousStep, int nextStep, var context) {
    var storage = Storage();

    switch(previousStep) {
      case 0: {
        //step 1
        final stepEnterAccountHeaderBloc = BlocProvider.of<StepEnterAccountHeaderBloc>(context);
        //final stepEnterAccountBloc = BlocProvider.of<StepEnterAccountBloc>(context);
        StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0);

        //show data on header if there is valid value
        if(storageStepEnterAccount.isUnlocked)
          stepEnterAccountHeaderBloc.add(AccountConfirmed(accountID: storageStepEnterAccount.accountID));
        else
          stepEnterAccountHeaderBloc.add(AccountRemoved());
      }
      break;

      case 1: {
        //statements;
      }
      break;

      default: {
        //statements;
      }
      break;
    }

    switch(nextStep){
      case 0:{
        final stepEnterAccountHeaderBloc = BlocProvider.of<StepEnterAccountHeaderBloc>(context);
        stepEnterAccountHeaderBloc.add(OpenStep());
      }
    }

  }

  @override
  Stream<StepperState> mapEventToState(StepperEvent event) async* {
    if (event is StepTapped) {
      yield state.copyWith(step: event.step);
    }
    else if (event is StepCancelled) {
      yield state.copyWith(
        step: state.step - 1 >= 0 ? state.step - 1 : 0,
      );
    }
    else if (event is StepContinue) {
      yield state.copyWith(
        step: state.step + 1 < maxSteps ? state.step + 1 : 0,
      );
    }
  }
}
