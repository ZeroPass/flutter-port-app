import 'package:eosign_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';


abstract class StepEnterAccountHeaderState extends Equatable {
  var showIconRemove;

  StepEnterAccountHeaderState({this.showIconRemove = false});

  @override
  List<Object> get props => [];
}

class OpenStepState extends StepEnterAccountHeaderState {

  OpenStepState(): super();

  @override
  String toString() => 'StepEnterAccountHeaderState:OpenStepState { showIconRemove: $showIconRemove }';
}

class NoAccountIDState extends StepEnterAccountHeaderState {

  NoAccountIDState(): super();

  @override
  String toString() => 'StepEnterAccountHeaderState:EmptyState { showIconRemove: $showIconRemove }';
}

class AccountIDState extends StepEnterAccountHeaderState {
  final String accountID;

  AccountIDState({@required this.accountID}){super.showIconRemove = true;}

  @override
  List<Object> get props => [accountID];

  @override
  String toString() => 'StepEnterAccountHeaderState:FullState { accoundID: $accountID, showIconRemove: $showIconRemove }';
}

