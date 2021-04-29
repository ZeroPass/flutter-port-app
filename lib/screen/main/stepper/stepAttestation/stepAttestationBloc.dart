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
import 'package:meta/meta.dart';

@JsonSerializable()
class OutsideCall{
  bool _isOutsideCall;
  String _requestedBy;

  OutsideCall OutsideCallFromJson({bool isOutsideCall, String requestedBy})
  {
    this._isOutsideCall = isOutsideCall;
    this._requestedBy = requestedBy;
    return this;
  }

  OutsideCall({@required String reqeustedBy})
  {
    _isOutsideCall = true;
    _requestedBy = reqeustedBy;
  }

  void removeRequestedBy()
  {
    _isOutsideCall = false;
    _requestedBy = null;
  }

  bool get isOutsideCall => _isOutsideCall;

  String get requestedBy => _requestedBy;

  factory OutsideCall.fromJson(Map<String, dynamic> json) => _$OutsideCallFromJson(json);
  Map<String, dynamic> toJson() => _$OutsideCallToJson(this);
}

OutsideCall _$OutsideCallFromJson(Map<String, dynamic> json) {
  OutsideCall obj = OutsideCall();
  return obj.OutsideCallFromJson(
        isOutsideCall: json['isOutsideCall'] as bool,
        requestedBy: json['requestedBy'] as String
  );
}

Map<String, dynamic> _$OutsideCallToJson(OutsideCall instance) => <String, dynamic>{
  'isOutsideCall' : instance.isOutsideCall,
  'requestedBy' : instance.requestedBy
};

@JsonSerializable()
class StepDataAttestation extends StepData{
  RequestType _requestType;
  OutsideCall _isOutsideCall;

  StepDataAttestation([@required this._requestType = null, @required this._isOutsideCall]) {
    if (this.requestType == null)
      this._requestType = RequestType.ATTESTATION_REQUEST; //default request type
  }

  StepDataAttestation StepDataAttestationFromJson({RequestType requestType, OutsideCall isOutsideCall})
  {
    this.requestType = requestType;
    this.isOutsideCall = isOutsideCall;
    return this;
  }

  RequestType get requestType => _requestType;

  set requestType(RequestType value) {
      if (requestType == null || MapUtil.contains(AuthenticatorActions, value) == false)
        throw Exception("StepDataAttestation:requestType:setter; not valid AuthenticatorAction");
      this._requestType = value;
  }

  OutsideCall get isOutsideCall => _isOutsideCall;

  set isOutsideCall(OutsideCall value) {
    _isOutsideCall = value;
  }

  factory StepDataAttestation.fromJson(Map<String, dynamic> json) => _$StepDataAttestationFromJson(json);
  Map<String, dynamic> toJson() => _$StepDataAttestationToJson(this);
}

StepDataAttestation _$StepDataAttestationFromJson(Map<String, dynamic> json) {
  StepDataAttestation obj = StepDataAttestation();
  return obj.StepDataAttestationFromJson(
    requestType: EnumUtil.fromStringEnum(RequestType.values, json['requestType']),
    isOutsideCall: OutsideCall.fromJson(json['isOutsideCall'])
  );
}

Map<String, dynamic> _$StepDataAttestationToJson(StepDataAttestation instance) => <String, dynamic>{
  'requestType': StringUtil.getWithoutTypeName(instance.requestType),
  'isOutsideCall' : instance.isOutsideCall
};


class StepAttestationBloc extends Bloc<StepAttestationEvent, StepAttestationState> {
  StepAttestationBloc({RequestType requestType}): super(AttestationWithDataState(requestType: requestType));

  @override
  StepAttestationState get initialState {
    Storage storage = Storage();
    StepDataAttestation stepDataAttestation = storage.getStorageData(2);
    return AttestationWithDataState(requestType: stepDataAttestation.requestType == null?
    RequestType.ATTESTATION_REQUEST: stepDataAttestation.requestType);
    }

    @override
    Stream<StepAttestationState> mapEventToState( StepAttestationEvent event) async* {
      if (event is AttestationEvent) {
        yield AttestationState();
      } else if (event is AttestationWithDataEvent) {
        yield AttestationWithDataState(requestType: event.requestType);
      }
    }
}
