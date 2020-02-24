import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class StepEnterAccountEvent extends Equatable {
  StepEnterAccountEvent();
}

class AccountConfirmation extends StepEnterAccountEvent{
  final String accountID;

  AccountConfirmation({@required this.accountID});

  @override
  List<Object> get props => [accountID];
}

class AccountDelete extends StepEnterAccountEvent{

  AccountDelete();

  @override
  List<Object> get props => [];
}