import 'package:port_mobile_app/utils/storage.dart';
import 'package:port_mobile_app/constants/constants.dart';

abstract class StepEnterAccountState {
  String? accountID;
  late NetworkType networkType;

  StepEnterAccountState({this.accountID, required this.networkType});

  @override
  List<Object> get props => [];
}

class DeletedState extends StepEnterAccountState {
  DeletedState( NetworkType networkType ) :super(networkType: networkType);

  @override
  String toString() => 'StepEnterAccountState:DeletedState { network type: $networkType }';
}

class FullState extends StepEnterAccountState {
  FullState({String? accountID, required NetworkType networkType}):
      super (accountID: accountID, networkType: networkType);

  @override
  String toString() => 'StepEnterAccountState:FullState { accountID: $accountID, network type: $networkType }';
}

class FullStateOutsideCall extends StepEnterAccountState {
  FullStateOutsideCall({String? accountID, required NetworkType networkType}):
        super (accountID: accountID, networkType: networkType);

  @override
  String toString() => 'StepEnterAccountState:FullStateOutsideCall { accountID: $accountID, network type: $networkType }';
}
