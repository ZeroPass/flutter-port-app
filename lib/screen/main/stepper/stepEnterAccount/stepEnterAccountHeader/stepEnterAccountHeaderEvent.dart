import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class StepEnterAccountHeaderEvent extends Equatable{
  StorageNode network;
  StorageServer server;

  StepEnterAccountHeaderEvent({@required this.network, @required this.server});
}

class WithoutAccountIDEvent extends StepEnterAccountHeaderEvent {

  WithoutAccountIDEvent({@required StorageNode network, @required StorageServer server = null}) : super(server: server, network: network){}

  @override
  List<Object> get props => [network, server];

  @override
  String toString() => 'StepEnterAccountHeaderEvent:WithoutAccountIDEvent';
}


class WithAccountIDEvent extends StepEnterAccountHeaderEvent{
  String accountID;

  WithAccountIDEvent({@required StorageNode network, @required this.accountID, @required StorageServer server = null}) : super(server: server, network: network);

  String getAccountID(){return this.accountID;}

  @override
  List<Object> get props => [network, accountID, server];

  @override
  String toString() => 'StepEnterAccountHeaderEvent:WithAccountIDEvent';
}

class WithAccountIDBufferEvent extends StepEnterAccountHeaderEvent{
  String accountID;

  WithAccountIDBufferEvent({@required StorageNode network, @required this.accountID, @required StorageServer server = null}) : super(server: server, network: network);

  @override
  List<Object> get props => [network, accountID, server];

  @override
  String toString() => 'StepEnterAccountHeaderEvent:WithAccountIDBufferEvent';
}