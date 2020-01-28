import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class StepperEvent extends Equatable {
  StepperEvent([List props = const[]]) : super();
  List<Object> get props => [props];
}

class StepTapped extends StepperEvent {
  final int step;

  StepTapped({@required this.step}) : super([step]);

  @override
  String toString() => 'StepTapped { step: $step }';
}

class StepCancelled extends StepperEvent {
  @override
  String toString() => 'StepCancelled';
}

class StepContinue extends StepperEvent {
  @override
  String toString() => 'StepContinue';
}