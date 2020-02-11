import 'package:equatable/equatable.dart';

abstract class StepScanState extends Equatable {
  @override
  List<Object> get props => [];
}

class EmptyState extends StepScanState {}

class FullState extends StepScanState {}

