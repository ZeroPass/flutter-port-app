import 'package:port_mobile_app/screen/flow/stepInputData/stepInputData.dart';

abstract class StepInputDataState {
  @override
  List<Object> get props => [];
}
class StepInputDataEmptyState extends StepInputDataState {
  @override
  String toString() => 'StepInputDataState:StepInputDataEmptyState';
}


class StepInputDataCanState extends StepInputDataState {
  String can;

  StepInputDataCanState({required this.can});

  @override
  String toString() => 'StepInputDataState:StepInputDataCanState';
}

class StepInputDataLegacyState extends StepInputDataState {
  DateTime dateOfBirth;
  DateTime dateOfExpiry;
  String documentNumber;

  StepInputDataLegacyState({required this.dateOfBirth, required this.dateOfExpiry, required this.documentNumber});

  @override
  String toString() => 'StepInputDataState:StepInputDataLegacyState {raw data: $documentNumber, date of birth: $dateOfBirth, date of expiry: $dateOfExpiry}';
}
