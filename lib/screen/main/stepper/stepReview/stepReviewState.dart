import 'package:eosio_port_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:eosio_port_mobile_app/screen/requestType.dart';
import 'package:dmrtd/dmrtd.dart';

import '../../../nfc/authn/authn.dart';

abstract class StepReviewState {
  @override
  List<Object> get props => [];
}

class StepReviewEmptyState extends StepReviewState{
}

class StepReviewBufferState extends StepReviewState {
  @override
  String toString() => 'StepReviewState:StepReviewBufferState';
}

class StepReviewNoConnectionState extends StepReviewState {
  @override
  String toString() => 'StepReviewState:StepReviewNoConnectionState';
}

class StepReviewWithoutDataState extends StepReviewState {
  RequestType requestType;
  AuthenticationType authType;
  OutsideCallV0dot1 outsideCall;
  String rawData;
  Function(bool) sendData;

  StepReviewWithoutDataState({required this.requestType, required this.authType, required this.rawData, required this.outsideCall, required this.sendData});

  @override
  String toString() => 'StepReviewState:StepReviewWithoutDataState {outside call: $outsideCall, auth type: $authType, raw data: $rawData,}}';
}

class StepReviewWithDataState extends StepReviewState {
  RequestType requestType;
  EfDG1 dg1;
  String msg;
  String rawData;
  OutsideCallV0dot1 outsideCall;
  Function(bool) sendData;

  StepReviewWithDataState({required this.requestType, required this.dg1, required this.msg, required this.rawData, required this.outsideCall, required this.sendData});

  @override
  String toString() => 'StepReviewState:StepReviewWithDataState {requestType: $requestType, dg1: filled, message: $msg, raw data: $rawData, outside call: $outsideCall}}';
}

class StepReviewCompletedState extends StepReviewState{
  RequestType requestType;
  String transactionID;
  String rawData;
  StepReviewCompletedState({required this.requestType, required this.transactionID, required this.rawData});

  @override
  String toString() => 'StepReviewState:StepReviewCompletedState {requestType: $requestType, transaction id: $transactionID, rawData: $rawData}}';
}
