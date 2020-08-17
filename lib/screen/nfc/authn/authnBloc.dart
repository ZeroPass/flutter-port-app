import "package:eosio_passid_mobile_app/screen/nfc/authn/authn.dart";
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

class AuthnBloc extends Bloc<AuthnEvent, AuthnState> {

  AuthnBloc(){}

  @override
  AuthnState get initialState => WithoutDataState();


  @override
  void onTransition(Transition<AuthnEvent, AuthnState> transition) {
    super.onTransition(transition);
  }

  @override
  Stream<AuthnState> mapEventToState( AuthnEvent event) async* {
    if (event is WithoutDataEvent)
      yield WithoutDataState();
    else if (event is WithDataEvent)
      yield WithDataState(dg1: event.dg1, msg: event.msg, sendData: event.sendData);
    else
      yield WithoutDataState();
    }
  }
