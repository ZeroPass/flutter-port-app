import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:equatable/equatable.dart';
import 'package:dmrtd/dmrtd.dart';
import 'package:flutter/cupertino.dart';

abstract class AuthnEvent extends Equatable {
  AuthnEvent();

  //@override
  List<Object> get props => [];
}

class WithoutDataEvent extends AuthnEvent{
  WithoutDataEvent(){}
}

class WithDataEvent extends AuthnEvent{
  EfDG1 dg1;
  String msg;
  OutsideCall outsideCall;
  Function(bool) sendData;

  WithDataEvent({@required this.dg1, @required this.msg, @required this.outsideCall, @required this.sendData});

  @override
  String toString() => 'AuthnEvent:WithDataEvent {dg1: filled, message: msg, outside call: $outsideCall}}';
}