import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class StepScanEvent /*extends Equatable*/ {
  StepScanEvent();
}

class NoDataScan extends StepScanEvent {

  NoDataScan();

  @override
  List<Object> get props => [];

  @override
  String toString() =>
      'NoDataScan ';
}

class WithDataScan extends StepScanEvent{
  //show documentID on header
  String? documentID;
  //show birth on header
  DateTime? birth;
  //show valid until on header
  DateTime? validUntil;

  WithDataScan({required this.documentID, required this.birth, required this.validUntil });

  //@override
  //List<Object> get props => [documentID, birth, validUntil];
}