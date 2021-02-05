/*
*
* Connector API to ZeroPass (first) server (written in python)
* Nejc Skerjanc (ZeroPass team)
*
*/
import 'package:dmrtd/src/extension/logging_apis.dart';
import 'package:logging/logging.dart';
import 'package:dmrtd/dmrtd.dart';
import 'package:passid/src/proto/session.dart';
import 'dart:async';

import 'package:passid/passid.dart';
import 'package:passid/internal.dart';
import 'package:eosio_passid_mobile_app/connection/connection.dart';

class ConnectorAPI extends ConnectionAdapterMaintenance with ConnectionAdapterAPI{
  PassIdApi passIdApi;
  final _log = Logger('ConnectionAPI; ConnectionAdapterMaintenance, ConnectionAdapterAPI');

  ConnectionAPI(String url, int port, int timeout/*in milliseconds*/){
    _log.fine("Connection API; url: $url, port: $port, timeout: $timeout");
    this._connectMaintenance(url, port, timeout);
    this._connect(url, port, timeout);
  }

  @override
  void _connectMaintenance(String url, int port, int timeout/*in milliseconds*/){
    _log.debug("ConnectionAPI.connectMaintenance with data: url:$url, port:$port, timeout:$timeout");
  }

  @override
  void _connect(String url, int port, int timeout/*in milliseconds*/){
    _log.debug("ConnectionAPI.connect with data: url:$url, port:$port, timeout:$timeout");
    passIdApi = PassIdApi(Uri.parse(url));
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
    _log.debug("ConnectionAPI.ping");
    Completer<int> send = new Completer<int>();
    passIdApi.ping(ping).then((pong) {
      send.complete(pong);
    });
    send.future;
  }

  @override
  Future<ProtoChallenge> getChallenge() async {
    _log.debug("ConnectionAPI.getChallenge");
    Completer<ProtoChallenge> send = new Completer<ProtoChallenge>();
    passIdApi.getChallenge().then((challenge) {
      send.complete(challenge);
    });
    send.future;
  }

  @override
  Future<void> cancelChallenge(ProtoChallenge protoChallenge) async {
    _log.debug("ConnectionAPI.cancelChallenge");
    Completer<void> send = new Completer<void>();
    passIdApi.cancelChallenge(protoChallenge).then((session) {
      send.complete();
    });
    send.future;
  }

  @override
  Future<Session> register(final EfSOD sod, final EfDG15 dg15, final CID cid, final ChallengeSignature csig, {EfDG14 dg14}) async {
    _log.debug("ConnectionAPI.register");
    Completer<Session> send = new Completer<Session>();
    passIdApi.register(sod, dg15, cid, csig, dg14: dg14).then((session) {
      send.complete(session);
    });
    send.future;
  }

  @override
  Future<Session> login(UserId uid, CID cid, ChallengeSignature csig, { EfDG1 dg1 }) async {
    _log.debug("ConnectionAPI.login");
    Completer<Session> send = new Completer<Session>();
    passIdApi.login(uid, cid, csig, dg1: dg1).then((session) {
      send.complete(session);
    });
    send.future;
  }

  @override
  Future<String> sayHello(Session session) async {
    _log.debug("ConnectionAPI.sayHello");
    Completer<String> send = new Completer<String>();
    passIdApi.sayHello(session).then((session) {
      send.complete(session);
    });
    send.future;
  }
}