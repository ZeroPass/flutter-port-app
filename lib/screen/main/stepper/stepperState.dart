import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class StepperState /*extends Equatable*/ {
  final int step;
  final int previousStep;
  final int maxSteps;

  StepperState({
    required this.step,
    required this.previousStep,
    required this.maxSteps
  });

  StepperState copyWith({required int step, required int previousStep, required int maxSteps}) {
    return StepperState(
          step: step, //?? this.step,
          previousStep: previousStep, //?? this.previousStep,
          maxSteps: maxSteps
    );
  }

  @override
  List<Object> get props => [step, previousStep, maxSteps];

  @override
  String toString() => 'StepperState { step: $step, prevoius step: $previousStep, maxSteps: $maxSteps }';

}

