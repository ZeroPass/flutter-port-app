import 'package:eosio_passid_mobile_app/utils/storage.dart';

abstract class StepEnterAccountState {
  var accountID;
  StorageNode network;

  StepEnterAccountState({this.accountID = null, this.network = null});

  @override
  List<Object> get props => [];
}

class DeletedState extends StepEnterAccountState {
  DeletedState( StorageNode network ){
    this.network = network;
  }

  @override
  String toString() => 'StepEnterAccountState:DeletedState { network: $network }';
}

class FullState extends StepEnterAccountState {
  FullState(String accountID, StorageNode network ){
    this.accountID = accountID;
    this.network = network;
  }

  @override
  String toString() => 'StepEnterAccountState:FullState { accountID: $accountID, network: $network }';
}
