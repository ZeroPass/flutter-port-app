import 'package:eosio_passid_mobile_app/screen/main/stepper/stepReview/stepReview.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

class StepReviewBloc extends Bloc<StepReviewEvent, StepReviewState> {

  StepReviewBloc(){}

  @override
  StepReviewState get initialState => StepReviewWithoutDataState();

  @override
  void onEvent(StepReviewEvent event) {
    // TODO: implement onEvent
    super.onEvent(event);
    print ("on alert");
  }

  @override
  void onTransition(Transition<StepReviewEvent, StepReviewState> transition) {
    print("on transition: -");
    super.onTransition(transition);
  }

  @override
  Stream<StepReviewState> mapEventToState( StepReviewEvent event) async* {
    if (event is StepReviewWithoutDataEvent)
      yield StepReviewWithoutDataState();
    else if (event is StepReviewWithDataEvent)
      yield StepReviewWithDataState(dg1: event.dg1, msg: event.msg, outsideCall: event.outsideCall, sendData: event.sendData);
    else
      yield StepReviewWithoutDataState();
    }
  }
