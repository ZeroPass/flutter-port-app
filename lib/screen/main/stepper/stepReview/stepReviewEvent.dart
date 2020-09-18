import 'package:eosio_passid_mobile_app/screen/requestType.dart';
import 'package:equatable/equatable.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:dmrtd/dmrtd.dart';
import 'package:meta/meta.dart';


abstract class StepReviewEvent extends Equatable {
  StepReviewEvent();

  //@override
  List<Object> get props => [];
}

class StepReviewWithoutDataEvent extends StepReviewEvent{
  StepReviewWithoutDataEvent(){}
}

class StepReviewWithDataEvent extends StepReviewEvent{
  EfDG1 dg1;
  String msg;
  OutsideCall outsideCall;
  Function(bool) sendData;

  StepReviewWithDataEvent({@required this.dg1, @required this.msg, @required this.outsideCall, @required this.sendData});

  @override
  String toString() => 'StepReviewEvent:StepReviewWithDataEvent {dg1: filled, message: msg, outside call: $outsideCall}}';
}

class StepReviewCompletedEvent extends StepReviewEvent{
  RequestType requestType;
  String transactionID;
  String rawData;
  StepReviewCompletedEvent({@required this.requestType, @required this.transactionID, @required this.rawData});

  @override
  String toString() => 'StepReviewEvent:StepReviewCompletedEvent {requestType: $requestType,  transaction id: $transactionID, rawData: $rawData}}';
}