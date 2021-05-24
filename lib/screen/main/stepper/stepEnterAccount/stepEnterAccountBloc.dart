import 'package:eosio_passid_mobile_app/constants/constants.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:bloc/bloc.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/utils/structure.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';


@JsonSerializable()
class StepDataEnterAccount extends StepData{
  String _accountID;
  NetworkType _networkType; //default network type

  StepDataEnterAccount() {
    this._accountID = null;
    this._networkType = NetworkType.MAINNET;
  }


  StepDataEnterAccount StepDataEnterAccountFromJson({String accountID, NetworkType networkType, bool hasData, bool isUnlocked})
  {
    this.accountID = accountID;
    this.networkType = networkType;
    this.hasData = hasData;
    this.isUnlocked = isUnlocked;
    return this;
  }

  String get accountID => _accountID;

  set accountID(String value) {

    this._accountID = value;
    //data is written(to check when we need to read from database)
    this.hasData = (value == "" || value == null ? false : true);
    //activate the button
    this.isUnlocked = (value == null || value.length <= 4 ? false : true);
  }

  factory StepDataEnterAccount.fromJson(Map<String, dynamic> json) => _$StepDataEnterAccountFromJson(json);
  Map<String, dynamic> toJson() => _$StepDataEnterAccountToJson(this);

  NetworkType get networkType => _networkType;

  set networkType(NetworkType value) {
    _networkType = value;
  }
}

StepDataEnterAccount _$StepDataEnterAccountFromJson(Map<String, dynamic> json) {
  StepDataEnterAccount obj = StepDataEnterAccount();
  return obj.StepDataEnterAccountFromJson(
    accountID: json['accountID'] as String,
    networkType: EnumUtil.fromStringEnum(NetworkType.values, json['networkType']),
    hasData: json['hasData'] as bool,
    isUnlocked: json['isUnlocked'] as bool,
  );
}

Map<String, dynamic> _$StepDataEnterAccountToJson(StepDataEnterAccount instance) => <String, dynamic>{
  'accountID': instance.accountID,
  'networkType': StringUtil.getWithoutTypeName(instance.networkType),
  'hasData': instance.hasData,
  'isUnlocked': instance.isUnlocked,
};


class StepEnterAccountBloc extends Bloc<StepEnterAccountEvent, StepEnterAccountState> {

  StepEnterAccountBloc({@required NetworkType networkType}): super(FullState(null, networkType)){
    this.updateDataOnUI();
  }

  //check if there is outside call
  bool checkOutsideCall(OutsideCallV0dot1 outsideCallV0dot1){
    return outsideCallV0dot1.isOutsideCall?true:false;
  }

  //check if there is any data stored
  void updateDataOnUI(){
      //check updated data
      Storage storage = Storage();
      storage.load(callback: (isAlreadyUpdated, isValid, {String exc}){
        if (isAlreadyUpdated == true || isValid == true){
          StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0);
          if (storage.outsideCall.isOutsideCall) {
            //updating network type:custom ; set the name of server
            NetworkChains.updateNetworkChainCustomAdd(url: storage.outsideCall.structV1.host.host);
            this.add(AccountConfirmationOutsideCall(
                accountID: storage.outsideCall.structV1.accountID,
                networkType: NetworkType.CUSTOM));
          }
          else if (storageStepEnterAccount.accountID != null)
            this.add(AccountConfirmation(accountID: storageStepEnterAccount.accountID,
                networkType: storageStepEnterAccount.networkType));
          else
            this.add(AccountDelete(networkType: storageStepEnterAccount.networkType));
        }
      });
  }

  var validatorText = '';

    @override
    void onTransition(Transition<StepEnterAccountEvent, StepEnterAccountState> transition) {
      super.onTransition(transition);
    }

    //separate function because of async function
    bool validatorFunction (String value, var context) {
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
      Storage storage = Storage();
      StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0);

      if (event is AccountConfirmation) {
        //change data in storage
        storageStepEnterAccount.accountID = event.accountID;
        yield FullState(event.accountID, event.networkType);
      }

      else if (event is AccountConfirmationOutsideCall) {
        //change data in storage outside call
        //storageStepEnterAccount.accountID = event.accountID;
        yield FullStateOutsideCall(event.accountID, event.networkType);
      }

      else if (event is AccountDelete) {
        //clear data in storage
        storageStepEnterAccount.accountID = null;
        storageStepEnterAccount.hasData = false;
        storageStepEnterAccount.isUnlocked = false;
        yield FullState(storageStepEnterAccount.accountID, event.networkType);
      }
      else yield DeletedState(storageStepEnterAccount.networkType);
    }
  }
