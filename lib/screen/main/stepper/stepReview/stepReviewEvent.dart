import 'package:equatable/equatable.dart';

abstract class StepReviewEvent extends Equatable {
  StepReviewEvent();

  //@override
  List<Object> get props => [];
}

class WithoutDataEvent extends StepReviewEvent{
  WithoutDataEvent(){}
}

class WithDataEvent extends StepReviewEvent{
  WithDataEvent(){}
}