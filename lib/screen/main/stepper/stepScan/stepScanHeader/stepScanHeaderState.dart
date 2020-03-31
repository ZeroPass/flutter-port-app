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
  String documentID;
  //show birth on header
  DateTime birth;
  //show valid until on header
  DateTime validUntil;

  WithDataState({String this.documentID = null, DateTime this.birth = null, DateTime this.validUntil = null});

  String getDocumentID(){return this.documentID;}

  DateTime getBirth(){return this.birth;}

  DateTime getValidUntil(){return this.validUntil;}

  @override
  List<Object> get props => [documentID, birth, validUntil];

  @override
  String toString() => 'StepScanHeaderState:WithDataState { documentID: $documentID, birth: $birth, validUntil: $validUntil }';
}
