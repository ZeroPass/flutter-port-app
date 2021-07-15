import 'package:eosio_port_mobile_app/screen/main/stepper/stepReview/stepReviewHeader/stepReviewHeader.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

class StepReviewHeaderBloc extends Bloc<StepReviewHeaderEvent, StepReviewHeaderState> {

  StepReviewHeaderBloc() : super(StepReviewHeaderWithoutDataState()){}

    //@override
    //StepReviewHeaderState get initialState => StepReviewHeaderWithoutDataState();


    @override
    void onError(Object error, StackTrace stacktrace) {
      super.onError(error, stacktrace);
    }

    @override
    void onTransition(Transition<StepReviewHeaderEvent, StepReviewHeaderState> transition) {
      super.onTransition(transition);
    }

    @override
    Stream<StepReviewHeaderState> mapEventToState( StepReviewHeaderEvent event) async* {
      if (event is StepReviewHeaderWithoutDataEvent)
        yield StepReviewHeaderWithoutDataState();
      else if (event is StepReviewHeaderWithDataEvent)
        yield StepReviewHeaderWithDataState();
    }
  }