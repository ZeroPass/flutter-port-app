import 'package:eosio_port_mobile_app/screen/requestType.dart';
import 'package:equatable/equatable.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:dmrtd/dmrtd.dart';
import '../../../nfc/authn/authn.dart';


abstract class StepReviewEvent extends Equatable {
  StepReviewEvent();

  //@override
  List<Object> get props => [];
}

class StepReviewEmptyEvent extends StepReviewEvent{
}

class StepReviewBufferEvent extends StepReviewEvent{
  StepReviewBufferEvent();

  @override
  String toString() => 'StepReviewEvent:StepReviewBufferEvent}';
}

class StepReviewNoConnectionEvent extends StepReviewEvent{
  StepReviewNoConnectionEvent();

  @override
  String toString() => 'StepReviewEvent:StepReviewNoConnectionEvent';
}

class StepReviewWithoutDataEvent extends StepReviewEvent{
  RequestType requestType;
  AuthenticationType authType;
  String rawData;
  OutsideCallV0dot1 outsideCall;
  Function(bool) sendData;

  StepReviewWithoutDataEvent({required this.requestType, required this.authType, required this.rawData,  required this.outsideCall, required this.sendData});

  @override
  String toString() => 'StepReviewEvent:StepReviewWithoutDataEvent {outside call: $outsideCall, auth type:$authType, raw data, $rawData}}';
}

class StepReviewWithDataEvent extends StepReviewEvent{
  RequestType requestType;
  EfDG1 dg1;
  String msg;
  String rawData;
  OutsideCallV0dot1 outsideCall;
  Function(bool) sendData;

  StepReviewWithDataEvent({required this.requestType, required this.dg1, required this.msg, required this.rawData, required this.outsideCall, required this.sendData});

  @override
  String toString() => 'StepReviewEvent:StepReviewWithDataEvent {requestType: $requestType, dg1: filled, message: msg, raw data: $rawData, outside call: $outsideCall}}';
}

class StepReviewCompletedEvent extends StepReviewEvent{
  RequestType requestType;
  String transactionID;
  String rawData;
  StepReviewCompletedEvent({required this.requestType, required this.transactionID, required this.rawData});

  @override
  String toString() => 'StepReviewEvent:StepReviewCompletedEvent {requestType: $requestType,  transaction id: $transactionID, rawData: $rawData}}';
}