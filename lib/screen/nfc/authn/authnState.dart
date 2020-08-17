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
  Function(bool) sendData;

  WithDataState({@required this.dg1, @required this.msg, @required this.sendData});

  @override
  String toString() => 'AuthnState:WithDataState {dg1: filled, message: $this.msg}}';
}
