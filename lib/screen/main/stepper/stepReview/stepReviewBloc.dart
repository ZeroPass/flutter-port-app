import 'package:eosio_passid_mobile_app/screen/main/stepper/stepReview/stepReview.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

class StepReviewBloc extends Bloc<StepReviewEvent, StepReviewState> {

  StepReviewBloc(){}

  @override
  StepReviewState get initialState => StepReviewEmptyState();

  @override
  void onTransition(Transition<StepReviewEvent, StepReviewState> transition) {
    super.onTransition(transition);
  }

  @override
  void onEvent(StepReviewEvent event) {
    super.onEvent(event);
  }


  @override
  Stream<StepReviewState> mapEventToState( StepReviewEvent event) async* {
    if (event is StepReviewEmptyEvent)
      yield StepReviewEmptyState();
    else if (event is StepReviewWithoutDataEvent)
      yield StepReviewWithoutDataState(requestType: event.requestType, rawData: event.rawData, outsideCall: event.outsideCall, sendData: event.sendData);
    else if (event is StepReviewWithDataEvent)
      yield StepReviewWithDataState(requestType: event.requestType, dg1: event.dg1, msg: event.msg, rawData: event.rawData, outsideCall: event.outsideCall, sendData: event.sendData);
    else if (event is StepReviewCompletedEvent)
      yield StepReviewCompletedState(requestType: event.requestType, transactionID: event.transactionID, rawData: event.rawData);
    else
      yield StepReviewEmptyState();
    }
  }
