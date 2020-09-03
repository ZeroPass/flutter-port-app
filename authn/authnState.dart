import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:meta/meta.dart';
import 'package:dmrtd/dmrtd.dart';

abstract class AuthnState {
  @override
  List<Object> get props => [];
}

class WithoutDataState extends AuthnState {
  @override
  String toString() => 'AuthnState:WithoutDataState';
}

class WithDataState extends AuthnState {
  EfDG1 dg1;
  String msg;
  OutsideCall outsideCall;
  Function(bool) sendData;

  WithDataState({@required this.dg1, @required this.msg, @required this.outsideCall, @required this.sendData});

  @override
  String toString() => 'AuthnState:WithDataState {dg1: filled, message: $msg, outside call: $outsideCall}}';
}
