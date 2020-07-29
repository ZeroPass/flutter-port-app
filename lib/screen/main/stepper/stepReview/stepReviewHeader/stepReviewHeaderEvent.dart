
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class StepReviewHeaderEvent extends Equatable{}

class NoDateEvent extends StepReviewHeaderEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'StepReviewHeaderEvent:NoDateEvent';
}