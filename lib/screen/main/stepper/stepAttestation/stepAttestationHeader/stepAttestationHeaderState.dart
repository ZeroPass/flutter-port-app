import 'package:eosio_passid_mobile_app/screen/requestType.dart';
import 'package:meta/meta.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';


abstract class StepAttestationHeaderState /*extends Equatable*/ {
  @override
  String toString() => 'StepAttestationHeaderState';
}
class AttestationHeaderWithDataState extends StepAttestationHeaderState {
  //show request type
  RequestType requestType;

  AttestationHeaderWithDataState({@required this.requestType});

  @override
  List<Object> get props => [requestType];

  @override
  String toString() => 'StepAttestationHeaderWithDataState:AttestationHeaderState { request type: $requestType }';
}