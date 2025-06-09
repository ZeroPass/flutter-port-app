import 'package:meta/meta.dart';


abstract class StepScanHeaderState /*extends Equatable*/ {
  StepScanHeaderState();

  @override
  List<Object> get props => [];
}

class WithoutDataState extends StepScanHeaderState {
  WithoutDataState();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'StepScanHeaderState:WithoutDataState';
}

class WithDataState extends StepScanHeaderState {
  //show documentID on header
  String? documentID;
  //show birth on header
  DateTime? birth;
  //show valid until on header
  DateTime? validUntil;
  //show CAN code on header
  String? can;

  WithDataState({this.documentID, this.birth, this.validUntil, this.can});


  bool isValidDocumentID() => documentID == null? false: true;

  String getDocumentID(){
    if (this.documentID != null)
      return this.documentID!;
    else
      throw Exception("StepScanState:documentID is null");
  }


  bool isValidBirth() => birth == null? false: true;

  DateTime getBirth(){
    if (this.birth != null)
      return this.birth!;
    else
      throw Exception("StepScanState:birth is null");
  }


  bool isValidValidUntil() => validUntil == null? false: true;

  DateTime getValidUntil(){
    if (this.validUntil != null)
      return this.validUntil!;
    else
      throw Exception("StepScanState:validUntil is null");
  }

  bool isValidCan() => can == null? false: true;

  String getCan(){
    if (this.can != null)
      return this.can!;
    else
      throw Exception("StepScanState:can is null");
  }

  //@override
  //List<Object> get props => [documentID, birth, validUntil];

  @override
  String toString() => 'StepScanHeaderState:WithDataState { documentID: $documentID, birth: $birth, validUntil: $validUntil, can: $can }';
}
