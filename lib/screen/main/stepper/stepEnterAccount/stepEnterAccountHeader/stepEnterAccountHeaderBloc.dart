import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:eosio_passid_mobile_app/utils/storage.dart';


class StepEnterAccountHeaderBloc extends Bloc<StepEnterAccountHeaderEvent, StepEnterAccountHeaderState> {

  StepEnterAccountHeaderBloc(){
    updateDataOnUI();
  }

  //check if there is any data stored
  void updateDataOnUI(){
    //check updated data
    Storage storage = Storage();
    storage.load(callback: (isAlreadyUpdated, isValid,  {String exc}){
      if (isAlreadyUpdated == true || isValid == true){
        StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0);
        if (storageStepEnterAccount.accountID != null && storageStepEnterAccount.accountID != "" )
          this.add(WithAccountIDEvent(accountID: storageStepEnterAccount.accountID,
                                      networkType: storageStepEnterAccount.networkType));
      }
    });
  }

    @override
    StepEnterAccountHeaderState get initialState {
    Storage storage = Storage();
    StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0);
    return WithoutAccountIDState(
        networkType: storageStepEnterAccount.networkType, server: storage.getServerCloudSelected(networkTypeServer: null));
    }

    @override
    void onError(Object error, StackTrace stacktrace) {
      super.onError(error, stacktrace);
    }

    @override
    void onTransition(Transition<StepEnterAccountHeaderEvent, StepEnterAccountHeaderState> transition) {
      super.onTransition(transition);
    }

    @override
    Stream<StepEnterAccountHeaderState> mapEventToState( StepEnterAccountHeaderEvent event) async* {

      if (event is WithAccountIDEvent) {
        yield WithAccountIDState(networkType: event.networkType, accountID: event.accountID);
      }
      else if (event is WithoutAccountIDEvent) {
        yield WithoutAccountIDState(networkType: event.networkType);
      }
      else {
        yield WithoutAccountIDState(networkType: event.networkType );
      }
    }
  }

