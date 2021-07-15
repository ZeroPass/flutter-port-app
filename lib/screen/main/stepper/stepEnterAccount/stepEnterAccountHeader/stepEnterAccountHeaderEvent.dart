import 'package:eosio_port_mobile_app/utils/storage.dart';
import 'package:eosio_port_mobile_app/constants/constants.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class StepEnterAccountHeaderEvent /*extends Equatable*/{
  NetworkType networkType;
  ServerCloud? server;

  StepEnterAccountHeaderEvent({required this.networkType});
}

class WithoutAccountIDEvent extends StepEnterAccountHeaderEvent {

  WithoutAccountIDEvent({required NetworkType networkType, ServerCloud? server}) : super(/*server: server,*/ networkType: networkType){}

  //@override
  //List<Object> get props => [networkType, server];

  @override
  String toString() => 'StepEnterAccountHeaderEvent:WithoutAccountIDEvent';
}


class WithAccountIDEvent extends StepEnterAccountHeaderEvent{
  String accountID;

  WithAccountIDEvent({required NetworkType networkType, required this.accountID}) : super( networkType: networkType);

  String getAccountID(){return this.accountID;}

  //@override
  //List<Object> get props => [networkType, accountID, server];

  @override
  String toString() => 'StepEnterAccountHeaderEvent:WithAccountIDEvent';
}

class WithAccountIDOutsideCallEvent extends StepEnterAccountHeaderEvent{
  String accountID;

  WithAccountIDOutsideCallEvent({required NetworkType networkType, required this.accountID}) : super( networkType: networkType);

  String getAccountID(){return this.accountID;}

  //@override
  //List<Object> get props => [networkType, accountID, server];

  @override
  String toString() => 'StepEnterAccountHeaderEvent:WithAccountIDOutsideCallEvent';
}

class WithAccountIDBufferEvent extends StepEnterAccountHeaderEvent{
  String accountID;

  WithAccountIDBufferEvent({required NetworkType networkType, required this.accountID}) : super( networkType: networkType);

  //@override
  //List<Object> get props => [networkType, accountID, server];

  @override
  String toString() => 'StepEnterAccountHeaderEvent:WithAccountIDBufferEvent';
}