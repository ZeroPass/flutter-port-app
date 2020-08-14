import 'package:eosio_passid_mobile_app/screen/main/stepper/stepReview/stepReview.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

class StepReviewBloc extends Bloc<StepReviewEvent, StepReviewState> {

  StepReviewBloc(){}

  @override
  StepReviewState get initialState => WithoutDataState();


  @override
  void onTransition(Transition<StepReviewEvent, StepReviewState> transition) {
    print("on transition: -");
    super.onTransition(transition);
  }

  @override
  Stream<StepReviewState> mapEventToState( StepReviewEvent event) async* {
    if (event is WithoutDataEvent)
      yield WithoutDataState();
    else if (event is WithDataEvent)
      yield WithDataState();
    else
      yield WithoutDataState();
    }
  }
