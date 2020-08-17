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
  Function(bool) sendData;

  WithDataEvent({@required this.dg1, @required this.msg, @required this.sendData});

  @override
  String toString() => 'AuthnEvent:WithDataEvent {dg1: filled, message: $this.msg}}';
}