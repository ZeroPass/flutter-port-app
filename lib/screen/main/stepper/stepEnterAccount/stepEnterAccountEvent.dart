import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';

abstract class StepEnterAccountEvent extends Equatable {
  StepEnterAccountEvent();
}

class AccountConfirmation extends StepEnterAccountEvent{
  final String accountID;
  final StorageNode network;

  AccountConfirmation({@required this.accountID, @required this.network});

  @override
  List<Object> get props => [accountID, network];
}

class AccountDelete extends StepEnterAccountEvent{
  final StorageNode network;

  AccountDelete({@required this.network});

  @override
  List<Object> get props => [network];
}