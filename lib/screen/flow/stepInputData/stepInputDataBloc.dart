import 'package:port_mobile_app/screen/flow/stepInputData/stepInputData.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StepInputDataBloc extends Bloc<StepInputDataEvent, StepInputDataState> {

  StepInputDataBloc() : super(StepInputDataEmptyState()) {
    on<StepInputDataCanEvent>((event, emit) =>
        emit (StepInputDataCanState(can: event.can)));

    on<StepInputDataLegacyEvent>((event, emit) =>
        emit (StepInputDataLegacyState(dateOfBirth: event.dateOfBirth,
                                       dateOfExpiry: event.dateOfExpiry,
                                       documentNumber: event.documentNumber
                                                                  )));
 }
  }
