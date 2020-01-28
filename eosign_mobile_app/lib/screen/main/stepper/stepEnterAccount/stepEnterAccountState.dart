import 'package:equatable/equatable.dart';

abstract class StepEnterAccountState extends Equatable {
  @override
  List<Object> get props => [];
}

class EmptyState extends StepEnterAccountState {}

class FullState extends StepEnterAccountState {}

