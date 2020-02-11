import 'package:eosign_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:eosign_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:bloc/bloc.dart';
import 'package:eosign_mobile_app/screen/main/stepper/stepper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import 'package:eosign_mobile_app/utils/storage.dart';

class StepDataEnterAccount extends StepData{
  String _accountID;

  StepDataEnterAccount(){
    _accountID = '';
  }

  String get accountID => _accountID;

  set accountID(String value) {
    _accountID = value;
    //data is written(to check when we need to read from database)
    this.hasData = true;
    //activate the button
    this.isUnlocked = true;

    }
}

class StepEnterAccountBloc extends Bloc<StepEnterAccountEvent, StepEnterAccountState> {
  //final int maxSteps;
  StepEnterAccountBloc(/*{@required this.maxSteps}*/);

  var validatorText = '';

  @override
  StepEnterAccountState get initialState => EmptyState();

  @override
  void onTransition(Transition<StepEnterAccountEvent, StepEnterAccountState> transition) {
    super.onTransition(transition);
    print(transition);
  }

  //separate function because of async function
  bool validatorFunction (String value, var context) {
    final stepEnterAccountBloc = BlocProvider.of<StepEnterAccountBloc>(context);


    //next button locked
    var storage = Storage();
    StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0);
    //Default value is false. If string passes all conditions then we change it on true
    storageStepEnterAccount.isUnlocked = false;

    //check the length of account name
    if (value.length > 13) {
      validatorText = 'Account name cannot be longer than 13 characters';
      return true;
    }

    //is EOS account name correct
    if (RegExp("^[a-z0-5.]{0,12}[a-p0-5]?\$").hasMatch(value) == false) {
      print("in reg");
      validatorText = 'Not allowed character. Allowed characters a-z and (\'.\') dot.';
      return true;
    }

    //when user type 5 or more characters, we check if account exists on chain after fixed time
    if (value.length > 4){
      stepEnterAccountBloc.accountExists(value, 2).then((value) {
        if (!value) {
          validatorText = 'Account name not found on chain1.';
          storageStepEnterAccount.isUnlocked = false;
          return true;
        }
        //unlock
        validatorText = '';
        storageStepEnterAccount.isUnlocked = true;
        return false;
      }, onError: (error) {
        validatorText = 'There is a problem with connection on chain.';
        return true;
      });
    };

    //final stepEnterAccountHeaderBloc = BlocProvider.of<StepEnterAccountHeaderBloc>(context);
    //stepEnterAccountHeaderBloc.

    final stepEnterAccountHeader = BlocProvider.of<StepEnterAccountHeaderBloc>(context);
    BlocProvider.of<StepEnterAccountHeaderBloc>(context).

    validatorText = '';
    // passes all conditions - only length is not checked - lower bound
    // make button disabled, but without warning
    if (value.length > 4)
      storageStepEnterAccount.isUnlocked = true;

    //StepEnterAccountHeader().account = "testni";
    return false;
  }

  Future<bool> accountExists (String accountName, int delaySec) async{
    //TODO: implement this function
    Future.delayed(Duration(seconds: delaySec), (){});
    return true;
  }

  @override
  Stream<StepEnterAccountState> mapEventToState( StepEnterAccountEvent event) async* {
    print("Step enter account bloc: mapEventToState");
    if (event is AccountConfirmation) {
      print("AccountConfirmation");
      yield FullState();
    } else if (event is AccountDelete) {
      print("StepCancelled");
      yield EmptyState();
    }
    else {
      print ("else event");
      yield EmptyState();
    }
  }
}
