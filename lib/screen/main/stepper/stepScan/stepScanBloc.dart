import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:bloc/bloc.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class StepDataScan extends StepData{
  String _documentID;
  DateTime _validUntil;
  DateTime _birth;

  StepDataScan(){
    _documentID = null;
    _validUntil = null;
    _birth = null;
  }

  StepDataScan StepDataScanFromJson({String documentID, DateTime birth, DateTime validUntil, bool hasData, bool isUnlocked}){
    this.documentID = documentID;
    this.birth = birth;
    this.validUntil = validUntil;
    this.hasData = hasData;
    this.isUnlocked = isUnlocked;
    return this;
  }

  String get documentID => _documentID;

  set documentID(String value) {
    _documentID = value;
  }

  DateTime get validUntil => _validUntil;

  set validUntil(DateTime value) {
    _validUntil = value;
  }

  DateTime get birth => _birth;

  set birth(DateTime value) {
    _birth = value;
  }

  factory StepDataScan.fromJson(Map<String, dynamic> json) => _$StepDataScanFromJson(json);
  Map<String, dynamic> toJson() => _$StepDataScanToJson(this);
}

StepDataScan _$StepDataScanFromJson(Map<String, dynamic> json) {
  StepDataScan obj = StepDataScan();
  return obj.StepDataScanFromJson(
    documentID: json['documentID'] != null ? json['documentID'] as String : null,
    birth: json['birth'] != null ? DateTime.parse(json['birth']) : null,
    validUntil: json['validUntil'] != null ?  DateTime.parse(json['validUntil']) : null,
    hasData: json['hasData'] as bool,
    isUnlocked: json['isUnlocked'] as bool,
  );
}

Map<String, dynamic> _$StepDataScanToJson(StepDataScan instance) => <String, dynamic>{
  'documentID': instance.documentID != null ? instance.documentID: null,
  'birth': instance.birth != null ? instance.birth.toIso8601String() : null,
  'validUntil': instance.validUntil != null ? instance.validUntil.toIso8601String() : null,
  'hasData': instance.hasData,
  'isUnlocked': instance.isUnlocked,
};

class StepScanBloc extends Bloc<StepScanEvent, StepScanState> {

  StepScanBloc() {
    this.updateDataOnUI();
  }

  //check if there is any data stored
  void updateDataOnUI(){
    //check updated data
    Storage storage = Storage();
    storage.load(callback: (isAlreadyUpdated, isValid,  {String exc}){
      if (isAlreadyUpdated == true || isValid == true){
        StepDataScan storageStepScan = storage.getStorageData(1);
        this.add(WithDataScan(documentID: storageStepScan.documentID,
            birth: storageStepScan.birth,
            validUntil: storageStepScan.validUntil));
      }
    });
  }


  var validatorText = '';

  @override
  StepScanState get initialState => StateScan();

  //separate function because of async function
  bool validatorFunction (String value, var context) {
    //next button locked
    var storage = Storage();
    StepDataScan storageStepScan = storage.getStorageData(1);
    //Default value is false. If string passes all conditions then we change it on true
    storageStepScan.isUnlocked = false;
    validatorText = '';
    return false;
    }

  Future<bool> accountExists (String accountName, int delaySec) async{
    //TODO: implement this function
    Future.delayed(Duration(seconds: delaySec), (){});
    return true;
  }

  @override
  Stream<StepScanState> mapEventToState( StepScanEvent event) async* {
    print("Step Scan bloc mapEventToState");
    if (event is WithDataScan) {
      yield FullState(documentID: event.documentID, birth: event.birth, validUntil: event.validUntil);
    } else if (event is NoDataScan) {
      yield StateScan();
    }
    else {
      yield StateScan();
    }
  }
}
