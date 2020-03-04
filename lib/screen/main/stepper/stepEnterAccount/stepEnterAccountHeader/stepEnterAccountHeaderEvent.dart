import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class StepEnterAccountHeaderEvent extends Equatable {
  StepEnterAccountHeaderEvent();
}

class AccountRemoved extends StepEnterAccountHeaderEvent {
  AccountRemoved(){}

  @override
  List<Object> get props => [];

  @override
  String toString() => 'StepEnterAccountHeaderEvent:AccountRemoved';
}

class AccountConfirmed extends StepEnterAccountHeaderEvent{
  final String accountID;

  AccountConfirmed({@required this.accountID});

  @override
  List<Object> get props => [accountID];
}

class OpenStep extends StepEnterAccountHeaderEvent {
  OpenStep(){}

  @override
  List<Object> get props => [];

  @override
  String toString() => 'StepEnterAccountHeaderEvent:OpenStep';
}
