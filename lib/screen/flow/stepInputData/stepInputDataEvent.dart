import 'package:equatable/equatable.dart';


abstract class StepInputDataEvent extends Equatable {
  StepInputDataEvent();

  //@override
  List<Object> get props => [];
}

class StepInputDataEmptyEvent extends StepInputDataEvent{
}

class StepInputDataCanEvent extends StepInputDataEvent{
  final String can;
  StepInputDataCanEvent({required this.can});

  @override
  List<Object> get props => [can];

  @override
  String toString() => 'StepInputDataEvent:StepInputDataCanEvent { can: $can }';
}

class StepInputDataLegacyEvent extends StepInputDataEvent{
  final DateTime dateOfBirth;
  final DateTime dateOfExpiry;
  final String documentNumber;

  StepInputDataLegacyEvent({required this.dateOfBirth,
                            required this.dateOfExpiry,
                            required this.documentNumber});

  @override
  List<Object> get props => [dateOfBirth, dateOfExpiry, documentNumber];

  @override
  String toString() => 'StepInputDataEvent:StepInputDataLegacyEvent { dateOfBirth: $dateOfBirth, dateOfExpiry: $dateOfExpiry, documentNumber: $documentNumber }';
}

