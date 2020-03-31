import 'package:equatable/equatable.dart';

abstract class StepAttestationState /*extends Equatable*/ {
  @override
  List<Object> get props => [];
}

class NotAllDataInStorage extends StepAttestationState {

  @override
  String toString() => 'StepAttestationState:NotAllDataInStorage';
}

class AllDataInStorage extends StepAttestationState {
  //show documentID on header
  String temp;

  AllDataInStorage({String this.temp = null});

  String getTemp(){return this.temp;}

  @override
  List<Object> get props => [temp];

  @override
  String toString() => 'FullState:StepScanState { temp: $temp}';
}

