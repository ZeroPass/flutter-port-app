import 'package:eosio_port_mobile_app/constants/constants.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:eosio_port_mobile_app/utils/storage.dart';


class StepEnterAccountHeaderBloc extends Bloc<StepEnterAccountHeaderEvent, StepEnterAccountHeaderState> {



  StepEnterAccountHeaderBloc({required NetworkType networkType}) :
        super(WithoutAccountIDState(networkType: networkType)){
    on<WithAccountIDEvent>((event, emit) => emit (WithAccountIDState(networkType: event.networkType, accountID: event.accountID)));
    on<WithAccountIDOutsideCallEvent>((event, emit) => emit (WithAccountIDOutsideCallState(networkType: event.networkType, accountID: event.accountID)));
    on<WithoutAccountIDEvent>((event, emit) => emit (WithoutAccountIDState(networkType: event.networkType)));

    updateDataOnUI();
  }

  //check if there is any data stored
  void updateDataOnUI(){
    //check updated data
    Storage storage = Storage();
    storage.load(callback: (isAlreadyUpdated, isValid,  {String? exc}){
      if (isAlreadyUpdated == true || isValid == true){
        StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0) as StepDataEnterAccount;

        if (storage.outsideCall.isOutsideCall) {
          //updating network type:custom ; set the name of server
          NetworkChains.updateNetworkChainCustomAdd(url: storage.outsideCall.getStructV1()!.host.host);
          this.add(WithAccountIDOutsideCallEvent(
              accountID: storage.outsideCall.getStructV1()!.accountID,
              networkType: NetworkType.CUSTOM));
        }
        else if (storageStepEnterAccount.accountID != "" )
          this.add(WithAccountIDEvent(accountID: storageStepEnterAccount.accountID,
                                      networkType: storageStepEnterAccount.networkType));
        else
          this.add(WithoutAccountIDEvent(networkType: storageStepEnterAccount.networkType));
      }
    });
  }

    @override
    StepEnterAccountHeaderState get initialState {
    Storage storage = Storage();
    StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0) as StepDataEnterAccount;
    return WithoutAccountIDState(
        networkType: storageStepEnterAccount.networkType,
        server: storage.getServerCloudSelected(networkTypeServer: NetworkTypeServer.MAIN_SERVER/*TODO: check if this is correct*/
        )
    );
    }

    /*
    @override
    Stream<StepEnterAccountHeaderState> mapEventToState( StepEnterAccountHeaderEvent event) async* {

      if (event is WithAccountIDEvent) {
        yield WithAccountIDState(networkType: event.networkType, accountID: event.accountID);
      }
      else if (event is WithAccountIDOutsideCallEvent) {
        yield WithAccountIDOutsideCallState(networkType: event.networkType, accountID: event.accountID);
      }
      else if (event is WithoutAccountIDEvent) {
        yield WithoutAccountIDState(networkType: event.networkType);
      }
      else {
        yield WithoutAccountIDState(networkType: event.networkType );
      }
    }*/
  }

