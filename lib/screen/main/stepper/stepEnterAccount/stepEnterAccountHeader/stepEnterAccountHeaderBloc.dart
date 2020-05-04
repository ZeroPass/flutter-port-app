import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:bloc/bloc.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart';
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
    storage.load(callback: (isAlreadyUpdated, isValid){
      if (isAlreadyUpdated == true || isValid == true){
        StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0);
        if (storageStepEnterAccount.accountID != null )
          this.add(WithAccountIDEvent(accountID: storageStepEnterAccount.accountID,
                                      network: storage.getNode()));
      }
    });
  }

    @override
    StepEnterAccountHeaderState get initialState {
    Storage storage = Storage();
    return WithoutAccountIDState(
        network: storage.getNode(), server: Storage().getStorageServer());
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
        yield WithAccountIDState(network: event.network, server: event.server, accountID: event.accountID);
      }
      else if (event is WithoutAccountIDEvent) {
        yield WithoutAccountIDState(network: event.network, server: event.server);
      }
      else {
        yield WithoutAccountIDState(network: event.network, server: event.server);
      }
    }

    @override
    Stream<StepEnterAccountHeaderState> transformStates(Stream<StepEnterAccountHeaderState> states) {
      // TODO: implement transformStates
      return super.transformStates(states);
    }
  }

