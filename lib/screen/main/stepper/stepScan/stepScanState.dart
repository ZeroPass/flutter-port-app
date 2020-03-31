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
  String documentID;
  //show birth on header
  DateTime birth;
  //show valid until on header
  DateTime validUntil;

  FullState({String this.documentID = null, DateTime this.birth = null, DateTime this.validUntil = null});

  String getDocumentID(){return this.documentID;}

  DateTime getBirth(){return this.birth;}

  DateTime getValidUntil(){return this.validUntil;}

  @override
  List<Object> get props => [documentID, birth, validUntil];

  @override
  String toString() => 'FullState:StepScanState { documentID: $documentID, birth: $birth, validUntil: $validUntil }';
}

