import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:eosio_passid_mobile_app/screen/requestType.dart';
import 'package:meta/meta.dart';
import 'package:dmrtd/dmrtd.dart';

abstract class StepReviewState {
  @override
  List<Object> get props => [];
}

class StepReviewWithoutDataState extends StepReviewState {
  @override
  String toString() => 'StepReviewState:StepReviewWithoutDataState';
}

class StepReviewWithDataState extends StepReviewState {
  EfDG1 dg1;
  String msg;
  OutsideCall outsideCall;
  Function(bool) sendData;

  StepReviewWithDataState({@required this.dg1, @required this.msg, @required this.outsideCall, @required this.sendData});

  @override
  String toString() => 'StepReviewState:StepReviewWithDataState {dg1: filled, message: $msg, outside call: $outsideCall}}';
}

class StepReviewCompletedState extends StepReviewState{
  RequestType requestType;
  String transactionID;
  String rawData;
  StepReviewCompletedState({@required this.requestType, @required this.transactionID, @required this.rawData});

  @override
  String toString() => 'StepReviewState:StepReviewCompletedState {requestType: $requestType, transaction id: $transactionID, rawData: $rawData}}';
}
