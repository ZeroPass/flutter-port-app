import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:eosio_passid_mobile_app/screen/requestType.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class StepAttestationEvent /*extends Equatable*/ {
  StepAttestationEvent();
}

class AttestationEvent extends StepAttestationEvent {

  AttestationEvent();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'StepAttestationEvent:AttestationEvent ';
}

class AttestationWithDataEvent extends StepAttestationEvent{
  //NFCDeviceData deviceData;
  RequestType requestType;

  AttestationWithDataEvent({@required this.requestType});

  @override
  List<Object> get props => [requestType];

  @override
  String toString() => 'StepAttestationEvent:AttestationWithDataEvent {requestType: $requestType}';
}

class AttestationWithDataOutsideCallEvent extends StepAttestationEvent{
  //NFCDeviceData deviceData;
  RequestType requestType;

  AttestationWithDataOutsideCallEvent({@required this.requestType});

  @override
  List<Object> get props => [requestType];

  @override
  String toString() => 'StepAttestationEvent:AttestationWithDataOutsideCallEvent {requestType: $requestType}';
}