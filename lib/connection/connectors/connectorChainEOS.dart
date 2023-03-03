/*
*
* Connector API to ZeroPass (first) server (written in python)
* Nejc Skerjanc (ZeroPass team)
*
*/
import 'package:dmrtd/dmrtd.dart';
import 'package:dmrtd/extensions.dart';
import 'package:eosio_port_mobile_app/utils/storage.dart';
import 'package:logging/logging.dart';

import 'dart:async';

import 'package:port/port.dart';
import 'package:eosio_port_mobile_app/connection/connection.dart';
import 'package:eosio_port_mobile_app/connection/tools/eosio/eosio.dart';

class ConnectorChainEOS extends ConnectionAdapterMaintenance with ConnectionAdapterAPI{
  late Eosio _eosio;
  late Keys _keys;
  final _log = Logger('ConnectorChainEOS; ConnectionAdapterMaintenance, ConnectionAdapterAPI');

  ConnectorChainEOS({required Uri url, int timeout = 15000, required Keys keys}){
    _log.fine("Connection API; url: $url, timeout: $timeout, keys length: ${keys.length}");
    this._keys = keys;
    this._connectMaintenance(url: url, timeout: timeout);
    this._connect(url: url, timeout: timeout);
    this._keys.clear(); //removed data; after we use it in sub-constructor
  }

  @override
  void _connectMaintenance({required Uri url, int timeout = 15000/*in milliseconds*/}){
    _log.debug("ConnectionAPI.connectMaintenance with data: url:$url, timeout:$timeout");
  }

  @override
  void _connect({required Uri url, int timeout = 15000/*in milliseconds*/}){
    _log.debug("ConnectionAPI.connect with data: url:$url, timeout:$timeout");

    if (_keys.isEmpty)
      throw Exception('Private key list is empty.');

    _eosio = Eosio(
        storageNode: NodeServer(host: url),
        version: EosioVersion.v1,
        privateKeys: _keys);

    this.ping(ping: 1).then((value){
      if (value == 1)
        _log.finest("Successfully connected on server ${url.toString()}");
      else
        _log.finest("Connection on server has failed (${url.toString()})");
    });
  }

  @override
  Future<APIresponse> uploadCSCA({required String cscaBinary}) async {
    _log.debug("ConnectionAPI.uploadCSCA");
    throw Exception("A function ConnectionAPI.uploadCSCA is not implemented yet.");
  }

  @override
  Future<APIresponse> removeCSCA({required String cscaBinary}) async {
    _log.debug("ConnectionAPI.uploadCSCA");
    throw Exception("A function ConnectionAPI.removeCSCA is not implemented yet.");
  }

  @override
  Future<APIresponse> uploadDSC({required String dscBinary}) async {
    _log.debug("ConnectionAPI.uploadCSCA");
    throw Exception("A function ConnectionAPI.uploadDSC is not implemented yet.");
  }

  @override
  Future<APIresponse> removeDSC({required String dscBinary}) async {
    _log.debug("ConnectionAPI.uploadCSCA");
    throw Exception("A function ConnectionAPI.removeDSC is not implemented yet.");
  }

  Future<APIresponse> getData({required String code, required String scope, required String table}) async {
    _log.debug("ConnectionAPI.getData");
    return await _eosio.getTableRows(code: code, scope: scope, table: table);
  }

  @override
  Future<int> ping({required int ping}) async {
    Completer<int> send = new Completer<int>();
    _eosio.getNodeInfo().then((value) => send.complete(value.successful? 1 : 0));
    return send.future;
  }

  /*@override
  Future<ProtoChallenge> getChallenge() async {
    _log.debug("ConnectionAPI.getChallenge");
    throw Exception("ConnectionAPI.getChallenge;  not implemented");
  }*/

  @override
  Future<void> cancelChallenge({required ProtoChallenge protoChallenge}) async {
    _log.debug("ConnectionAPI.cancelChallenge");
    throw Exception("ConnectionAPI.cancelChallenge;  not implemented");
  }

  @override
  Future<Map<String, dynamic>> register({required final UserId userId,required final EfSOD sod,required final EfDG15 dg15,required final CID cid,required final ChallengeSignature csig, EfDG14? dg14}) async {
    _log.debug("ConnectionAPI.register");
    throw Exception("ConnectionAPI.register;  not implemented");
  }

  @override
  Future<Map<String, dynamic>> getAssertion({required UserId uid, required CID cid, required ChallengeSignature csig}) async {
    _log.debug("ConnectionAPI.login");
    throw Exception("ConnectionAPI.login;  not implemented");
  }

  @override
  Future<int> sayHello({required int number}) async {
    _log.debug("ConnectionAPI.sayHello");
    throw Exception("ConnectionAPI.sayHello;  not implemented");
  }
}