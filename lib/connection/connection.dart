import 'dart:async';
import 'package:port/port.dart';
import 'package:dmrtd/dmrtd.dart';

class Connection{
  dynamic _connector;

  Connection ({required dynamic connector}):
  this._connector = connector;


  void uploadCSCA(){
    this._connector.uploadCSCA();
  }

  void uploadDSC(){
    this._connector.uploadDSC();
  }
}


class APIresponse{
  bool _successful;

  bool get successful => _successful;

  set successful(bool value) {
    _successful = value;
  }

  int _statusCode;

  int get statusCode => _statusCode;

  set statusCode(int value) {
    _statusCode = value;
  }

  String _text;

  String get text => _text;

  set text(String value) {
    _text = value;
  }

  dynamic? _data;

  dynamic get data => _data;

  set data(dynamic value) {
    _data = value;
  }



  APIresponse(this._successful, {dynamic data, String text = "", int code = 200}):
  this._statusCode = code,
  this._text = text,
  this._data = data;

}


abstract class ConnectionAdapterMaintenance{
  void _connectMaintenance({required Uri url, int timeout = 15000/*in milliseconds*/});

  Future<APIresponse> uploadCSCA({required String cscaBinary});
  Future<APIresponse> removeCSCA({required String cscaBinary});

  Future<APIresponse> uploadDSC({required String dscBinary});
  Future<APIresponse> removeDSC({required String dscBinary});
}


abstract class ConnectionAdapterAPI{
  void _connect({required Uri url, int timeout = 15000/*in milliseconds*/});

  Future<int> ping({required int ping});
  //Future<ProtoChallenge> getChallenge();
  Future<void> cancelChallenge({required ProtoChallenge protoChallenge});
  Future<Map<String, dynamic>> register({required final UserId userId, required final EfSOD sod, required final EfDG15 dg15, required final CID cid, required final ChallengeSignature csig, EfDG14 dg14});
  Future<Map<String, dynamic>> getAssertion({required UserId uid, required CID cid, required ChallengeSignature csig});
  Future<int> sayHello({required int number});

}