import 'package:port_mobile_app/utils/storage.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:port_mobile_app/screen/requestType.dart';

abstract class StepAttestationHeaderEvent /*extends Equatable*/{
  @override
  String toString() => 'StepAttestationHeaderEvent';
}

class AttestationHeaderWithDataEvent extends StepAttestationHeaderEvent {
  RequestType requestType;

  @override
  List<Object> get props => [requestType];

  AttestationHeaderWithDataEvent({required this.requestType});

  @override
  String toString() => 'StepAttestationHeaderEvent:AttestationHeaderWithDataEvent {request type: $requestType}';
}

class AttestationHeaderWithDataOutsideCallEvent extends StepAttestationHeaderEvent {
  RequestType requestType;

  @override
  List<Object> get props => [requestType];

  AttestationHeaderWithDataOutsideCallEvent({required this.requestType});

  @override
  String toString() => 'StepAttestationHeaderEvent:AttestationHeaderWithDataOutsideCallEvent {request type: $requestType}';
}