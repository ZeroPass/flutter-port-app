import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
//import "package:eosio_passid_mobile_app/screen/main/stepper/StepEnterAccount/StepEnterAccountHeader/StepEnterAccountHeader.dart" as SEAHB;
import 'package:bloc/bloc.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart';
import 'package:eosio_passid_mobile_app/settings/settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:meta/meta.dart';

class StepDataEnterAccount extends StepData{
  String _accountID;

  StepDataEnterAccount(){
    this._accountID = "";
  }

  String get accountID => _accountID;

  set accountID(String value) {

    this._accountID = value;
    //data is written(to check when we need to read from database)
    this.hasData = (value == "" ? false : true);
    //activate the button
    this.isUnlocked = (value.length <= 4 ? false : true);
    }
}

class StepEnterAccountBloc extends Bloc<StepEnterAccountEvent, StepEnterAccountState> {
  var _storage;
  StepEnterAccountBloc(){
    _storage = Storage();
  }

  var validatorText = '';

  @override
  StepEnterAccountState get initialState => FullState('');

  @override
  void onTransition(Transition<StepEnterAccountEvent, StepEnterAccountState> transition) {
    super.onTransition(transition);
  }

  /*void updateHeader (var text, var context) {
    var _storage = Storage();
    StepDataEnterAccount storageStepEnterAccount =
    _storage.getStorageData(0);
    storageStepEnterAccount.accountID = text;
  }*/


  //separate function because of async function
  bool validatorFunction (String value, var context) {
    print("in validator");
    final stepEnterAccountBloc = BlocProvider.of<StepEnterAccountBloc>(context);

    //next button locked
    var storage = Storage();
    StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0);
    //write accountID value to storage - no matter if it is correct
    //storageStepEnterAccount.accountID = value;

    //Default value is false. If string passes all conditions then we change it on true
    storageStepEnterAccount.isUnlocked = false;

    //check the length of account name
    if (value.length > 13) {
      validatorText = 'Account name cannot be longer than 13 characters';
      return true;
    }

    //is EOS account name correct
    if (RegExp("^[a-z1-5.]{0,12}[a-j1-5]?\$").hasMatch(value) == false) {
      print("in reg");
      validatorText = 'Not allowed character. Allowed characters a-z and (\'.\') dot.';
      return true;
    }

    //when user type 5 or more characters, we check if account exists on chain after fixed time
    if (value.length > 4){
      stepEnterAccountBloc.accountExists(value, 2).then((value) {
        if (!value) {
          validatorText = 'Account name not found on chain.';
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

    validatorText = '';
    // passes all conditions - only length is not checked - lower bound
    // make button disabled, but without warning
    if (value.length > 4)
      storageStepEnterAccount.isUnlocked = true;

    storageStepEnterAccount.accountID = value;
    return false;
  }

  Future<bool> accountExists (String accountName, int delaySec) async{
    //TODO: implement this function
    Future.delayed(Duration(seconds: delaySec), (){});
    return true;
  }

  @override
  Stream<StepEnterAccountState> mapEventToState( StepEnterAccountEvent event) async* {
    if (event is AccountConfirmation) {
      //change data in storage
      StepDataEnterAccount storageStepEnterAccount = _storage.getStorageData(0);
      storageStepEnterAccount.accountID = event.accountID;
      yield FullState(event.accountID);
    } else if (event is AccountDelete) {
      //clear data in storage
      StepDataEnterAccount storageStepEnterAccount = _storage.getStorageData(0);
      //yield DeletedState();
      storageStepEnterAccount.accountID = '';
      storageStepEnterAccount.isUnlocked = false;
      yield FullState(storageStepEnterAccount.accountID);
    }
    else yield DeletedState();
  }
}
