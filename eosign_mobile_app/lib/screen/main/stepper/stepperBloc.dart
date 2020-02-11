import 'package:eosign_mobile_app/screen/main/stepper/stepper.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';


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
  List<StepData> _stepsDescription;

  StepperBloc({@required this.maxSteps}){
  }

  @override
  StepperState get initialState => StepperState(step: 0, maxSteps: maxSteps);

  @override
  void onTransition(Transition<StepperEvent, StepperState> transition) {
    super.onTransition(transition);
    print(transition);
  }

  @override
  Stream<StepperState> mapEventToState(StepperEvent event) async* {
    if (event is StepTapped) {
      yield state.copyWith(step: event.step);
    } else if (event is StepCancelled) {
      yield state.copyWith(
        step: state.step - 1 >= 0 ? state.step - 1 : 0,
      );
    } else if (event is StepContinue) {
      yield state.copyWith(
        step: state.step + 1 < maxSteps ? state.step + 1 : 0,
      );
    }
  }
}
