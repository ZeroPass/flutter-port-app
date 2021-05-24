import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:bloc/bloc.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestationHeader/stepAttestationHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart';
import 'package:eosio_passid_mobile_app/screen/requestType.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:json_annotation/json_annotation.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/utils/structure.dart';
import 'package:eosio_passid_mobile_app/screen/qr/structure.dart';
import 'package:meta/meta.dart';

import 'package:logging/logging.dart';
import 'package:dmrtd/src/extension/logging_apis.dart';


final _logOutsideCall = Logger("OutsideCall");

@JsonSerializable()
class OutsideCall{
  bool _isOutsideCall;

  OutsideCall OutsideCallFromJson({bool isOutsideCall, Server requestedBy})
  {
    this._isOutsideCall = isOutsideCall;
    return this;
  }

  OutsideCall({@required bool isOutsideCall})
  {
    _logOutsideCall.debug("Setting outside call var: $_isOutsideCall .");
    _isOutsideCall = isOutsideCall;
  }

  void set()
  {
    _logOutsideCall.debug("Setting outside call to true.");
    _isOutsideCall = true;
  }

  void remove()
  {
    _logOutsideCall.debug("Setting outside call to false.");
    _isOutsideCall = false;
  }

  bool get isOutsideCall => _isOutsideCall;

  // we should not use two serialization/deserialization functions to store
  // in the database
  factory OutsideCall.fromJson(Map<String, dynamic> json) => _$OutsideCallFromJson(json);
  Map<String, dynamic> toJson() => _$OutsideCallToJson(this);
}

OutsideCall _$OutsideCallFromJson(Map<String, dynamic> json) {
  OutsideCall obj = OutsideCall();
  return obj.OutsideCallFromJson(
        isOutsideCall: json['isOutsideCall'] as bool
  );
}

Map<String, dynamic> _$OutsideCallToJson(OutsideCall instance) => <String, dynamic>{
  'isOutsideCall' : instance.isOutsideCall
};

final _logOutsideCallV0dot1 = Logger("OutsideCallV0dot1");

@JsonSerializable()
class OutsideCallV0dot1 extends OutsideCall{
  QRserverStructure _structV1; //can be null

  OutsideCallV0dot1 () : super(isOutsideCall: false){
    _logOutsideCallV0dot1.debug("Constructor: setting outside call to false");
    this._structV1 = null;
  }

  void set({@required QRserverStructure qRserverStructure}) {
    _logOutsideCallV0dot1.debug("Setting structure to oustside call");
    super.set();
    if (qRserverStructure == null)
      throw Exception("QRserverStructure must not be null when you set outside call");
    this.structV1 = qRserverStructure;
  }

  void remove() {
    _logOutsideCallV0dot1.debug("Removing outside call v1");
    super.remove();
    this.structV1 = null;
  }

  QRserverStructure get structV1 => _structV1;

  set structV1(QRserverStructure value) {
    _structV1 = value;
  }
}

@JsonSerializable()
class StepDataAttestation extends StepData{
  RequestType _requestType;
  //OutsideCallV0dot1 _isOutsideCall;

  StepDataAttestation({@required RequestType requestType}) {
    if (this.requestType == null)
      this._requestType = RequestType.ATTESTATION_REQUEST; //default request type
  }

  StepDataAttestation StepDataAttestationFromJson({RequestType requestType})
  {
    this.requestType = requestType;
    return this;
  }

  RequestType get requestType => _requestType;

  set requestType(RequestType value) {
      if (requestType == null || MapUtil.contains(AuthenticatorActions, value) == false)
        throw Exception("StepDataAttestation:requestType:setter; not valid AuthenticatorAction");
      this._requestType = value;
  }

  factory StepDataAttestation.fromJson(Map<String, dynamic> json) => _$StepDataAttestationFromJson(json);
  Map<String, dynamic> toJson() => _$StepDataAttestationToJson(this);
}

StepDataAttestation _$StepDataAttestationFromJson(Map<String, dynamic> json) {
  StepDataAttestation obj = StepDataAttestation();
  return obj.StepDataAttestationFromJson(
    requestType: EnumUtil.fromStringEnum(RequestType.values, json['requestType'])
  );
}

Map<String, dynamic> _$StepDataAttestationToJson(StepDataAttestation instance) => <String, dynamic>{
  'requestType': StringUtil.getWithoutTypeName(instance.requestType)
};


class StepAttestationBloc extends Bloc<StepAttestationEvent, StepAttestationState> {
  StepAttestationBloc({RequestType requestType}): super(AttestationWithDataState(requestType: requestType)) {
    this.updateDataOnUI();
  }
    //check if there is any data stored
    void updateDataOnUI(){
      //check updated data
      Storage storage = Storage();
      storage.load(callback: (isAlreadyUpdated, isValid, {String exc}){
        if (isAlreadyUpdated == true || isValid == true){
          if (storage.outsideCall.isOutsideCall)
            this.add(AttestationWithDataOutsideCallEvent(requestType: storage.outsideCall.structV1.requestType));
          else {
            StepDataAttestation stepDataAttestation = storage.getStorageData(2);
            this.add(AttestationWithDataEvent(
                requestType: stepDataAttestation.requestType == null ?
                RequestType.ATTESTATION_REQUEST : stepDataAttestation
                    .requestType));
          }
        }
      });
    }

    @override
    Stream<StepAttestationState> mapEventToState( StepAttestationEvent event) async* {
      if (event is AttestationEvent) {
        yield AttestationState();
      } else if (event is AttestationWithDataEvent) {
        yield AttestationWithDataState(requestType: event.requestType);
      }
      else if (event is AttestationWithDataOutsideCallEvent) {
        yield AttestationWithDataOutsideCallState(requestType: event.requestType);
      }
    }
}
