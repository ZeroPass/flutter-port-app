import 'package:equatable/equatable.dart';

abstract class StepScanState /*extends Equatable*/ {
  @override
  List<Object> get props => [];
}

class StateScan extends StepScanState {

  @override
  String toString() => 'StepScanState:EmptyState';
}

class FullState extends StepScanState {
  //show documentID on header
  String? documentID;
  //show birth on header
  DateTime? birth;
  //show valid until on header
  DateTime? validUntil;

  FullState({String? this.documentID, DateTime? this.birth, DateTime? this.validUntil});

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

  @override
  String toString() => 'FullState:StepScanState { documentID: $documentID, birth: $birth, validUntil: $validUntil }';
}

