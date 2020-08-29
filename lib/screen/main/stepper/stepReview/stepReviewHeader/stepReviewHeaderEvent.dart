
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class StepReviewHeaderEvent extends Equatable{}

class StepReviewHeaderWithoutDataEvent extends StepReviewHeaderEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'StepReviewHeaderEvent:StepReviewHeaderWithoutDataEvent';
}

class StepReviewHeaderWithDataEvent extends StepReviewHeaderEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'StepReviewHeaderEvent:StepReviewHeaderWithDataEvent';
}