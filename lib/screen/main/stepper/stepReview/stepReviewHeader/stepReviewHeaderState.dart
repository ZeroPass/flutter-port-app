import 'package:meta/meta.dart';
import 'package:eosio_port_mobile_app/utils/storage.dart';


abstract class StepReviewHeaderState /*extends Equatable*/ {
  @override
  List<Object> get props => [];
}

class StepReviewHeaderWithoutDataState extends StepReviewHeaderState {
  @override
  String toString() => 'StepReviewHeaderState:StepReviewHeaderWithoutDataState';
}

class StepReviewHeaderWithDataState extends StepReviewHeaderState {
  @override
  String toString() => 'StepReviewHeaderState:StepReviewHeaderWithDataState';
}