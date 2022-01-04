import 'package:eosio_port_mobile_app/screen/main/stepper/stepReview/stepReview.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

class StepReviewBloc extends Bloc<StepReviewEvent, StepReviewState> {

  StepReviewBloc() : super(StepReviewEmptyState()) {
    on<StepReviewEmptyEvent>((event, emit) => emit (StepReviewEmptyState()));
    on<StepReviewBufferEvent>((event, emit) => emit (StepReviewBufferState()));
    on<StepReviewNoConnectionEvent>((event, emit) => emit (StepReviewNoConnectionState()));
    on<StepReviewWithoutDataEvent>((event, emit) => emit (StepReviewWithoutDataState(requestType: event.requestType, rawData: event.rawData, outsideCall: event.outsideCall, sendData: event.sendData)));
    on<StepReviewWithDataEvent>((event, emit) => emit (StepReviewWithDataState(requestType: event.requestType, dg1: event.dg1, msg: event.msg, rawData: event.rawData, outsideCall: event.outsideCall, sendData: event.sendData)));
    on<StepReviewCompletedEvent>((event, emit) => emit (StepReviewCompletedState(requestType: event.requestType, transactionID: event.transactionID, rawData: event.rawData)));
  }

  //@override
  //StepReviewState get initialState => StepReviewEmptyState();



  /*@override
  Stream<StepReviewState> mapEventToState( StepReviewEvent event) async* {
    if (event is StepReviewEmptyEvent)
      yield StepReviewEmptyState();
    else if (event is StepReviewBufferEvent)
      yield StepReviewBufferState();
    else if (event is StepReviewNoConnectionEvent)
      yield StepReviewNoConnectionState();

    else if (event is StepReviewWithoutDataEvent)
      yield StepReviewWithoutDataState(requestType: event.requestType, rawData: event.rawData, outsideCall: event.outsideCall, sendData: event.sendData);
    else if (event is StepReviewWithDataEvent)
      yield StepReviewWithDataState(requestType: event.requestType, dg1: event.dg1, msg: event.msg, rawData: event.rawData, outsideCall: event.outsideCall, sendData: event.sendData);
    else if (event is StepReviewCompletedEvent)
      yield StepReviewCompletedState(requestType: event.requestType, transactionID: event.transactionID, rawData: event.rawData);
    else
      yield StepReviewEmptyState();
    }*/
  }
