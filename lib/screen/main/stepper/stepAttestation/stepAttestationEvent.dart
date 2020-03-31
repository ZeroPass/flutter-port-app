import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class StepAttestationEvent extends Equatable {
  StepAttestationEvent();
}

class NotAllDataInStorageEvent extends StepAttestationEvent {

  NotAllDataInStorageEvent();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'StepAttestationEvent:NotAllDataInStorageEvent ';
}

class AllDataInStorageEvent extends StepAttestationEvent{
  //show temp on header
  String temp;

  AllDataInStorageEvent({@required this.temp});

  @override
  List<Object> get props => [temp];
}