import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';


abstract class StepEnterAccountHeaderState extends Equatable {
  const StepEnterAccountHeaderState();

  @override
  List<Object> get props => [];
}

class NoAccountIDState extends StepEnterAccountHeaderState {

  @override
  String toString() => 'StepEnterAccountHeaderState:EmptyState';
}

class AccountIDState extends StepEnterAccountHeaderState {
  final String accountID;

  AccountIDState({@required this.accountID});

  @override
  List<Object> get props => [accountID];

  @override
  String toString() => 'StepEnterAccountHeaderState:FullState { accoundID: $accountID }';
}

