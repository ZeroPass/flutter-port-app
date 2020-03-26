import 'package:equatable/equatable.dart';

abstract class StepEnterAccountState /*extends Equatable*/ {
  var accountID;

  StepEnterAccountState({this.accountID = ''});

  @override
  List<Object> get props => [];
}

class DeletedState extends StepEnterAccountState {
  DeletedState(): super();

  @override
  String toString() => 'StepEnterAccountState:DeletedState { accountID: $accountID }';
}

class FullState extends StepEnterAccountState {
  FullState(String accountID){
    this.accountID = accountID;
  }

  @override
  String toString() => 'StepEnterAccountState:FullState { accountID: $accountID }';
}

