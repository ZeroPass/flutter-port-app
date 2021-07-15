import 'package:eosio_port_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:bloc/bloc.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import 'package:eosio_port_mobile_app/utils/storage.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class StepDataScan extends StepData{
  late String? _documentID;
  late DateTime? _validUntil;
  late DateTime? _birth;

  StepDataScan(){
    _documentID = null;
    _validUntil = null;
    _birth = null;
  }

  StepDataScan StepDataScanFromJson({String? documentID, DateTime? birth, DateTime? validUntil, required bool hasData, required bool isUnlocked}){
    this._documentID = documentID;
    this._birth = birth;
    this._validUntil = validUntil;
    this.hasData = hasData;
    this.isUnlocked = isUnlocked;
    return this;
  }

  bool isValidDocumentID() => _documentID == null? false: true;

  String getDocumentID(){
    if (this._documentID != null)
      return this._documentID!;
    else
      throw Exception("StepDataScan:documentID is null");
  }

  set documentID(String? value) {
    _documentID = value;
  }


  bool isValidBirth() => _birth == null? false: true;

  DateTime getBirth(){
    if (this._birth != null)
      return this._birth!;
    else
      throw Exception("StepDataScan:birth is null");
  }

  set birth(DateTime? value) {
    _birth = value;
  }


  bool isValidValidUntil() => _validUntil == null? false: true;

  DateTime getValidUntil(){
    if (this._validUntil != null)
      return this._validUntil!;
    else
      throw Exception("StepDataScan:validUntil is null");
  }

  set validUntil(DateTime? value) {
    _validUntil = value;
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
  'documentID': instance.isValidDocumentID() ? instance.getDocumentID(): null,
  'birth': instance.isValidBirth() ? instance.getBirth().toIso8601String() : null,
  'validUntil': instance.isValidValidUntil() ? instance.getValidUntil().toIso8601String() : null,
  'hasData': instance.hasData,
  'isUnlocked': instance.isUnlocked,
};

class StepScanBloc extends Bloc<StepScanEvent, StepScanState> {

  StepScanBloc(): super(StateScan()) {
    this.updateDataOnUI();
  }

  //check if there is any data stored
  void updateDataOnUI(){
    //check updated data
    Storage storage = Storage();
    storage.load(callback: (isAlreadyUpdated, isValid,  {String? exc}){
      if (isAlreadyUpdated == true || isValid == true){
        StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
        this.add(WithDataScan(documentID: storageStepScan.isValidDocumentID()?storageStepScan.getDocumentID(): null,
            birth: storageStepScan.isValidBirth()?storageStepScan.getBirth(): null,
            validUntil: storageStepScan.isValidValidUntil()?storageStepScan.getValidUntil(): null));
      }
    });
  }


  var validatorText = '';

  //@override
  //StepScanState get initialState => StateScan();

  //separate function because of async function
  bool validatorFunction (String value, var context) {
    //next button locked
    var storage = Storage();
    StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
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
