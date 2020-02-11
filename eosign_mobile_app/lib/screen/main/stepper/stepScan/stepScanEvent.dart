import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class StepScanEvent extends Equatable {
  StepScanEvent();
}

class NoAccount extends StepScanEvent {

  NoAccount();

  @override
  List<Object> get props => [];

  //@override
  //String toString() =>
  //    'LoginButtonPressed { username: $username, password: $password }';
}

class AccountConfirmation extends StepScanEvent{
  final String accountID;

  AccountConfirmation({@required this.accountID});

  @override
  List<Object> get props => [accountID];
}

class AccountDelete extends StepScanEvent{

  AccountDelete();

  @override
  List<Object> get props => [];
}