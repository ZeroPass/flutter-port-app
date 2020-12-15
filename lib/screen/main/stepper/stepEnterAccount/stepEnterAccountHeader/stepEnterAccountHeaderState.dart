import 'package:eosio_passid_mobile_app/constants/constants.dart';
import 'package:meta/meta.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';


abstract class StepEnterAccountHeaderState /*extends Equatable*/ {
  //show network name in header
  NetworkType networkType;
  //show one time server icon on header
  ServerCloud server;

  StepEnterAccountHeaderState({this.networkType, this.server = null});

  @override
  List<Object> get props => [networkType, server];
}

class WithoutAccountIDState extends StepEnterAccountHeaderState {

  WithoutAccountIDState({@required NetworkType networkType, ServerCloud server = null}) : super(networkType: networkType, server: server);

  @override
  List<Object> get props => [networkType, server];

  @override
  String toString() => 'StepEnterAccountHeaderState:WithoutAccountIDState { network type: $networkType }';
}

class WithAccountIDState extends StepEnterAccountHeaderState {
  //show accountID in header
  String accountID;

  WithAccountIDState({@required NetworkType networkType, @required String this.accountID, ServerCloud server = null}) : super(networkType: networkType, server: server){}

  String getAccountID(){return this.accountID;}

  @override
  List<Object> get props => [accountID, networkType, server];

  @override
  String toString() => 'StepEnterAccountHeaderState:WithAccountIDState { network type: $networkType, accoundID: $accountID }';
}
