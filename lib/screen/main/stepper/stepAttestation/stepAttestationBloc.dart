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

//propse of class is easer presentation of data - not to save anywhere
class NFCDeviceData {
  //passport data
  NFCdeviceType _deviceType;
  String _NFCdeviceNumber;
  DateTime _dateOfExpiration;
  String _countryOfIssuer;

  //personal data
  String _name;
  String _lastName;
  DateTime _dateOfBirth;
  Sex _sex;
  String _nationality;
  String _additionalData;

  NFCdeviceType get deviceType => _deviceType;

  set deviceType(NFCdeviceType value) {
    _deviceType = value;
  }

  String get additionalData => _additionalData;

  set additionalData(String value) {
    _additionalData = value;
  }

  String get nationality => _nationality;

  set nationality(String value) {
    _nationality = value;
  }

  Sex get sex => _sex;

  set sex(Sex value) {
    _sex = value;
  }

  DateTime get dateOfBirth => _dateOfBirth;

  set dateOfBirth(DateTime value) {
    _dateOfBirth = value;
  }

  String get lastName => _lastName;

  set lastName(String value) {
    _lastName = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get countryOfIssuer => _countryOfIssuer;

  set countryOfIssuer(String value) {
    _countryOfIssuer = value;
  }

  DateTime get dateOfExpiration => _dateOfExpiration;

  set dateOfExpiration(DateTime value) {
    _dateOfExpiration = value;
  }

  String get NFCdeviceNumber => _NFCdeviceNumber;

  set NFCdeviceNumber(String value) {
    _NFCdeviceNumber = value;
  }

  @override
  String toString() {
    return 'NFCDeviceData{_deviceType: $_deviceType, _NFCdeviceNumber: $_NFCdeviceNumber, _dateOfExpiration: $_dateOfExpiration, _countryOfIssuer: $_countryOfIssuer, _name: $_name, _lastName: $_lastName, _dateOfBirth: $_dateOfBirth, _sex: $_sex, _nationality: $_nationality, _additionalData: $_additionalData}';
  }

  Map printToMap(){
    Map<String, dynamic> output =
    {"Passport type": deviceType,
      "Passport no.": NFCdeviceNumber,
      "Date of expiry": dateOfExpiration,
      "Issuing country:": countryOfIssuer,
      "Name": name,
      "Last name": lastName,
      "Date of Birth": dateOfBirth,
      "Sex": sex,
      "Nationality": nationality,
      "Additional data": additionalData
    };
    return output;
  }
}


@JsonSerializable()
class StepDataAttestation extends StepData{
  RequestType _requestType;
  bool _isOutsideCall;

  StepDataAttestation([@required this._isOutsideCall, this._requestType = null,]) {
    if (this.requestType == null)
      this._requestType = RequestType.ATTESTATION_REQUEST; //default request type
  }

  StepDataAttestation StepDataAttestationFromJson({RequestType requestType, bool isOutsideCall})
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

  bool get isOutsideCall => _isOutsideCall;

  set isOutsideCall(bool value) {
    _isOutsideCall = value;
  }

  factory StepDataAttestation.fromJson(Map<String, dynamic> json) => _$StepDataAttestationFromJson(json);
  Map<String, dynamic> toJson() => _$StepDataAttestationToJson(this);
}

StepDataAttestation _$StepDataAttestationFromJson(Map<String, dynamic> json) {
  StepDataAttestation obj = StepDataAttestation();
  return obj.StepDataAttestationFromJson(
    requestType: EnumUtil.fromStringEnum(RequestType.values, json['requestType']),
    isOutsideCall: json['isOutsideCall']
  );
}

Map<String, dynamic> _$StepDataAttestationToJson(StepDataAttestation instance) => <String, dynamic>{
  'requestType': StringUtil.getWithoutTypeName(instance.requestType),
  'isOutsideCall' : instance.isOutsideCall
};


class StepAttestationBloc extends Bloc<StepAttestationEvent, StepAttestationState> {
  StepAttestationBloc();

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
