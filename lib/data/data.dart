import 'package:port_mobile_app/utils/storage.dart';
import 'package:json_annotation/json_annotation.dart';

abstract class BasicData{
  late bool _isUnlocked;
  late bool _hasData;

  BasicData(){
    _isUnlocked = false;
    _hasData = false;
  }

  bool get isUnlocked => _isUnlocked;

  set isUnlocked(bool value) {
    _isUnlocked = value;
  }

  bool get hasData => _hasData;

  set hasData(bool value) {
    _hasData = value;
  }
}

@JsonSerializable()
class LegacyData extends BasicData{
  late String? _documentID;
  late DateTime? _validUntil;
  late DateTime? _birth;

  LegacyData(){
    _documentID = null;
    _validUntil = null;
    _birth = null;
  }

  LegacyData LegacyDataFromJson({String? documentID, DateTime? birth, DateTime? validUntil, required bool hasData, required bool isUnlocked}){
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
      throw Exception("LegacyData:documentID is null");
  }

  set documentID(String? value) {
    _documentID = value;
  }


  bool isValidBirth() => _birth == null? false: true;

  DateTime getBirth(){
    if (this._birth != null)
      return this._birth!;
    else
      throw Exception("LegacyData:birth is null");
  }

  set birth(DateTime? value) {
    _birth = value;
  }


  bool isValidValidUntil() => _validUntil == null? false: true;

  DateTime getValidUntil(){
    if (this._validUntil != null)
      return this._validUntil!;
    else
      throw Exception("LegacyData:validUntil is null");
  }

  set validUntil(DateTime? value) {
    _validUntil = value;
  }

  factory LegacyData.fromJson(Map<String, dynamic> json) => _$LegacyDataFromJson(json);
  Map<String, dynamic> toJson() => _$LegacyDataToJson(this);
}

LegacyData _$LegacyDataFromJson(Map<String, dynamic> json) {
  LegacyData obj = LegacyData();
  return obj.LegacyDataFromJson(
    documentID: json['documentID'] != null ? json['documentID'] as String : null,
    birth: json['birth'] != null ? DateTime.parse(json['birth']) : null,
    validUntil: json['validUntil'] != null ?  DateTime.parse(json['validUntil']) : null,
    hasData: json['hasData'] as bool,
    isUnlocked: json['isUnlocked'] as bool,
  );
}

Map<String, dynamic> _$LegacyDataToJson(LegacyData instance) => <String, dynamic>{
  'documentID': instance.isValidDocumentID() ? instance.getDocumentID(): null,
  'birth': instance.isValidBirth() ? instance.getBirth().toIso8601String() : null,
  'validUntil': instance.isValidValidUntil() ? instance.getValidUntil().toIso8601String() : null,
  'hasData': instance.hasData,
  'isUnlocked': instance.isUnlocked,
};


@JsonSerializable()
class CanData extends BasicData{
  late String? _can;

  CanData(){
    _can = null;
  }

  CanData CanDataFromJson({String? can, required bool hasData, required bool isUnlocked}){
    this._can = can;
    this.hasData = hasData;
    this.isUnlocked = isUnlocked;
    return this;
  }

  bool isValidCan() => _can == null? false: true;

  String getCan(){
    if (this._can != null)
      return this._can!;
    else
      throw Exception("CanData:can is null");
  }

  set can(String? value) {
    _can = value;
  }

  factory CanData.fromJson(Map<String, dynamic> json) => _$CanDataFromJson(json);
  Map<String, dynamic> toJson() => _$CanDataToJson(this);
}

CanData _$CanDataFromJson(Map<String, dynamic> json) {
  CanData obj = CanData();
  return obj.CanDataFromJson(
    can: json['can'] != null ? json['can'] as String : null,
    hasData: json['hasData'] as bool,
    isUnlocked: json['isUnlocked'] as bool,
  );
}

Map<String, dynamic> _$CanDataToJson(CanData instance) => <String, dynamic>{
  'can': instance.isValidCan() ? instance.getCan(): null,
  'hasData': instance.hasData,
  'isUnlocked': instance.isUnlocked,
};