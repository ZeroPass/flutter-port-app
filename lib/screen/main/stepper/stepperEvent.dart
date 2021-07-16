import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class StepperEvent extends Equatable {
  StepperEvent() : super();
  List<Object> get props => [props];
}

class StepTapped extends StepperEvent {
  final int step;
  final int previousStep;

  StepTapped({required this.step, required this.previousStep});

  @override
  String toString() => 'StepTapped { step: $step, previous step:$previousStep }';
}

class StepRunByFlow extends StepperEvent {
  final int step;
  final int previousStep;

  StepRunByFlow({required this.step, required this.previousStep});

  @override
  String toString() => 'StepRunByFlow { step: $step, previous step:$previousStep }';
}

class StepAfterQR extends StepperEvent {
  final int previousStep;

  StepAfterQR({required this.previousStep});

  @override
  String toString() => 'StepRunByFlow { previous step:$previousStep }';
}

class StepCancelled extends StepperEvent {

  @override
  String toString() => 'StepCancelled';
}

class StepContinue extends StepperEvent {
  late int stepsJump;
  final int previousStep;

  StepContinue({this.stepsJump = 1, required this.previousStep}) {}

  @override
  String toString() => 'StepContinue (stepsJump: $stepsJump, previous step: $previousStep)';
}

class StepBackToPrevious extends StepperEvent {

  @override
  String toString() => 'StepBackToPrevious ';
}