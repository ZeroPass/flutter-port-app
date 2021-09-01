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

  String _text;

  String get text => _text;

  set text(String value) {
    _text = value;
  }

  APIresponse(this._successful, this._text);
}


abstract class ConnectionAdapterMaintenance{
  void _connectMaintenance(Uri url, int timeout/*in milliseconds*/);

  Future<APIresponse> uploadCSCA(String cscaBinary);
  Future<APIresponse> removeCSCA(String cscaBinary);

  Future<APIresponse> uploadDSC(String dscBinary);
  Future<APIresponse> removeDSC(String dscBinary);
}


abstract class ConnectionAdapterAPI{
  void _connect(Uri url, int timeout/*in milliseconds*/);

  Future<int> ping(int ping);
  //Future<ProtoChallenge> getChallenge();
  Future<void> cancelChallenge(ProtoChallenge protoChallenge);
  Future<Map<String, dynamic>> register(final UserId userId, final EfSOD sod, final EfDG15 dg15, final CID cid, final ChallengeSignature csig, {EfDG14 dg14});
  Future<Map<String, dynamic>> getAssertion(UserId uid, CID cid, ChallengeSignature csig);
  Future<int> sayHello(int number);

}