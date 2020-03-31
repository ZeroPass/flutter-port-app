import 'package:equatable/equatable.dart';

abstract class StepScanHeaderEvent extends Equatable{
  StepScanHeaderEvent();
}

class NoDataEvent extends StepScanHeaderEvent {

  NoDataEvent(){}

  @override
  List<Object> get props => [];

  @override
  String toString() => 'StepScanHeaderEvent:NoDataEvent';
}


class WithDataEvent extends StepScanHeaderEvent{
  //show documentID on header
  String documentID;
  //show birth on header
  DateTime birth;
  //show valid until on header
  DateTime validUntil;

  WithDataEvent({String this.documentID = null, DateTime this.birth = null, DateTime this.validUntil = null});

  String getDocumentID(){return this.documentID;}

  DateTime getBirth(){return this.birth;}

  DateTime getValidUntil(){return this.validUntil;}

  @override
  List<Object> get props => [documentID, birth, validUntil];

  @override
  String toString() => 'StepScanHeaderEvent:WithAccountIDEvent';
}
