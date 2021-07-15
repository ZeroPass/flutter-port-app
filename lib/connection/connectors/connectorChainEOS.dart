/*
*
* Connector API to ZeroPass (first) server (written in python)
* Nejc Skerjanc (ZeroPass team)
*
*/
import 'package:dmrtd/src/extension/logging_apis.dart';
import 'package:eosio_port_mobile_app/utils/storage.dart';
import 'package:logging/logging.dart';
import 'package:dmrtd/dmrtd.dart';
import 'package:port/src/proto/session.dart';
import 'dart:async';

import 'package:port/port.dart';
import 'package:port/internal.dart';
import 'package:eosio_port_mobile_app/connection/connection.dart';
import 'package:eosio_port_mobile_app/connection/tools/eosio/eosio.dart';

class ConnectorChainEOS extends ConnectionAdapterMaintenance with ConnectionAdapterAPI{
  late Eosio _eosio;
  late Keys _keys;
  final _log = Logger('ConnectorChainEOS; ConnectionAdapterMaintenance, ConnectionAdapterAPI');

  ConnectorChainEOS(Uri url, int timeout, Keys keys){
    _log.fine("Connection API; url: $url, timeout: $timeout, keys length: ${keys.length}");
    this._keys = keys;
    this._connectMaintenance(url, timeout);
    this._connect(url, timeout);
    this._keys.clear(); //removed data; after we use it in sub-constructor
  }

  @override
  void _connectMaintenance(Uri url, int timeout/*in milliseconds*/){
    _log.debug("ConnectionAPI.connectMaintenance with data: url:$url, timeout:$timeout");
  }

  @override
  void _connect(Uri url, int timeout/*in milliseconds*/){
    _log.debug("ConnectionAPI.connect with data: url:$url, timeout:$timeout");

    if (_keys.isEmpty)
      throw Exception('Private key list is empty.');

    _eosio = Eosio(
        NodeServer(host: url),
        EosioVersion.v2,
        _keys);
  }

  @override
  Future<APIresponse> uploadCSCA(String cscaBinary) async {
    _log.debug("ConnectionAPI.uploadCSCA");
    throw Exception("A function ConnectionAPI.uploadCSCA is not implemented yet.");
  }

  @override
  Future<APIresponse> removeCSCA(String cscaBinary) async {
    _log.debug("ConnectionAPI.uploadCSCA");
    throw Exception("A function ConnectionAPI.removeCSCA is not implemented yet.");
  }

  @override
  Future<APIresponse> uploadDSC(String dscBinary) async {
    _log.debug("ConnectionAPI.uploadCSCA");
    throw Exception("A function ConnectionAPI.uploadDSC is not implemented yet.");
  }

  @override
  Future<APIresponse> removeDSC(String dscBinary) async {
    _log.debug("ConnectionAPI.uploadCSCA");
    throw Exception("A function ConnectionAPI.removeDSC is not implemented yet.");
  }

  @override
  Future<int> ping(int ping) async {
    Completer<int> send = new Completer<int>();
    _eosio.getNodeInfo().then((value){

      send.complete(value != null? 1 : 0);
    });
    return send.future;
  }

  @override
  Future<ProtoChallenge> getChallenge() async {
    _log.debug("ConnectionAPI.getChallenge");
    throw Exception("ConnectionAPI.getChallenge;  not implemented");
  }

  @override
  Future<void> cancelChallenge(ProtoChallenge protoChallenge) async {
    _log.debug("ConnectionAPI.cancelChallenge");
    throw Exception("ConnectionAPI.cancelChallenge;  not implemented");
  }

  @override
  Future<Session> register(final EfSOD sod, final EfDG15 dg15, final CID cid, final ChallengeSignature csig, {EfDG14? dg14}) async {
    _log.debug("ConnectionAPI.register");
    throw Exception("ConnectionAPI.register;  not implemented");
  }

  @override
  Future<Session> login(UserId uid, CID cid, ChallengeSignature csig, { EfDG1? dg1 }) async {
    _log.debug("ConnectionAPI.login");
    throw Exception("ConnectionAPI.login;  not implemented");
  }

  @override
  Future<String> sayHello(Session session) async {
    _log.debug("ConnectionAPI.sayHello");
    throw Exception("ConnectionAPI.sayHello;  not implemented");
  }
}