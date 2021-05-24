import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/constants/constants.dart';

abstract class StepEnterAccountState {
  var accountID;
  NetworkType networkType;

  StepEnterAccountState({this.accountID = null, this.networkType = null});

  @override
  List<Object> get props => [];
}

class DeletedState extends StepEnterAccountState {
  DeletedState( NetworkType networkType ){
    this.networkType = networkType;
  }

  @override
  String toString() => 'StepEnterAccountState:DeletedState { network type: $networkType }';
}

class FullState extends StepEnterAccountState {
  FullState(String accountID, NetworkType networkType){
    this.accountID = accountID;
    this.networkType = networkType;
  }

  @override
  String toString() => 'StepEnterAccountState:FullState { accountID: $accountID, network type: $networkType }';
}

class FullStateOutsideCall extends StepEnterAccountState {
  FullStateOutsideCall(String accountID, NetworkType networkType){
    this.accountID = accountID;
    this.networkType = networkType;
  }

  @override
  String toString() => 'StepEnterAccountState:FullStateOutsideCall { accountID: $accountID, network type: $networkType }';
}
