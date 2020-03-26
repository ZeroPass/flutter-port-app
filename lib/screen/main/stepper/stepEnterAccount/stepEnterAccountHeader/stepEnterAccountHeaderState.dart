import 'package:meta/meta.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';


abstract class StepEnterAccountHeaderState /*extends Equatable*/ {
  //show network name in header
  StorageNode network;
  //show one time server icon on header
  StorageServer server;

  StepEnterAccountHeaderState({this.network, this.server = null});

  @override
  List<Object> get props => [network, server];
}

class WithoutAccountIDState extends StepEnterAccountHeaderState {

  WithoutAccountIDState({@required StorageNode network, StorageServer server = null}) : super(network: network, server: server);

  @override
  List<Object> get props => [network, server];

  @override
  String toString() => 'StepEnterAccountHeaderState:WithoutAccountIDState { network: $network }';
}

class WithAccountIDState extends StepEnterAccountHeaderState {
  //show accountID in header
  String accountID;

  WithAccountIDState({@required StorageNode network, @required String this.accountID, StorageServer server = null}) : super(network: network, server: server){}

  String getAccountID(){return this.accountID;}

  @override
  List<Object> get props => [accountID, network, server];

  @override
  String toString() => 'StepEnterAccountHeaderState:WithAccountIDState { network: $network, accoundID: $accountID }';
}
