import 'package:meta/meta.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';


abstract class StepReviewHeaderState /*extends Equatable*/ {
  @override
  List<Object> get props => [];
}

class NoDataState extends StepReviewHeaderState {
  @override
  String toString() => 'StepReviewHeaderState:NoDataState';
}