import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class StepperState extends Equatable {
  final int step;
  final int maxSteps;

  StepperState({
    @required this.step,
    @required this.maxSteps,
  });

  StepperState copyWith({int step, int maxSteps}) {
    return StepperState(
      step: step ?? this.step,
      maxSteps: maxSteps ?? this.maxSteps,
    );
  }

  @override
  List<Object> get props => [step, maxSteps];

  @override
  String toString() => 'StepperState { step: $step, maxSteps: $maxSteps }';

}

