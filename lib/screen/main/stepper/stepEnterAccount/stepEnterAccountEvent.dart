import 'package:port_mobile_app/constants/constants.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:port_mobile_app/utils/storage.dart';

abstract class StepEnterAccountEvent extends Equatable {
  StepEnterAccountEvent();
}

class AccountConfirmation extends StepEnterAccountEvent{
  final String accountID;
  final NetworkType networkType;

  AccountConfirmation({required this.accountID, required this.networkType});

  @override
  List<Object> get props => [accountID, networkType];
}

class AccountConfirmationOutsideCall extends StepEnterAccountEvent{
  final String accountID;
  final NetworkType networkType;

  AccountConfirmationOutsideCall({required this.accountID, required this.networkType});

  @override
  List<Object> get props => [accountID, networkType];
}

class AccountDelete extends StepEnterAccountEvent{
  final NetworkType networkType;

  AccountDelete({required this.networkType});

  @override
  List<Object> get props => [networkType];
}