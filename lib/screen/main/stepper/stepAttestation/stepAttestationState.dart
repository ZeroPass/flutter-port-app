import 'package:eosio_port_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:eosio_port_mobile_app/screen/requestType.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

abstract class StepAttestationState /*extends Equatable*/ {
  @override
  List<Object> get props => [];
}

class AttestationState extends StepAttestationState {

  @override
  String toString() => 'StepAttestationState:AttestationState';
}

class AttestationWithDataState extends StepAttestationState {
  //NFCDeviceData deviceData;
  RequestType requestType;

  AttestationWithDataState({required this.requestType});

  @override
  List<Object> get props => [requestType];

  @override
  String toString() => 'StepAttestationState:AttestationWithDataState { request type: $requestType}';
}

class AttestationWithDataOutsideCallState extends StepAttestationState {
  //NFCDeviceData deviceData;
  RequestType requestType;

  AttestationWithDataOutsideCallState({required this.requestType});

  @override
  List<Object> get props => [requestType];

  @override
  String toString() => 'StepAttestationState:AttestationWithDataOutsideCallState { request type: $requestType}';
}

