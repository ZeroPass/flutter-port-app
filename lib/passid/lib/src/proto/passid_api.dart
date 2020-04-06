//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.

import 'dart:io';
import 'package:dmrtd/dmrtd.dart';
import 'package:dmrtd/extensions.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:passid/passid.dart';

import 'rpc/jrpc.dart';
import 'rpc/jrpc_objects.dart';

import 'passid_error.dart';
import 'proto_challenge.dart';
import 'session.dart';
import 'uid.dart';


class PassIdApi {
  final _log = Logger('passid.api');
  final JRPClient _rpc;
  static const String _apiPrefix = 'passID.';

  Duration get timeout => _rpc.httpClient.connectionTimeout;
  set timeout(Duration timeout) => _rpc.httpClient.connectionTimeout = timeout;

  Uri get url => _rpc.url;
  set url(Uri url) => _rpc.url = url;

  PassIdApi(Uri url, {HttpClient httpClient}) :
     _rpc = JRPClient(url, httpClient: httpClient ?? HttpClient());


/******************************************** API CALLS *****************************************************/
/************************************************************************************************************/

  /// API: passID.ping
  /// Sends [ping] and returns [pong] received from server.
  /// Can throw [JRPClientError], [PassIdError] and [SocketException] on connection errors.
  Future<int> ping(int ping) async {
    _log.debug('passID.ping($ping) =>');
    final resp = await _transceive(method: 'ping', params: {'ping': ping });
    _throwIfError(resp);

    final pong = resp['pong'] as int;
    _log.debug('passID.ping <= pong: $pong');
    return pong;
  }

  /// API: passID.getChallenge
  /// Returns [ProtoChallenge] from server.
  /// Can throw [JRPClientError], [PassIdError] and [SocketException] on connection errors.
  Future<ProtoChallenge> getChallenge() async {
    _log.debug('passID.getChallenge() =>');
    final resp = await _transceive(method: 'getChallenge');
    _throwIfError(resp);

    final c = ProtoChallenge.fromJson(resp);
    _log.debug('passID.getChallenge <= challenge: ${c.data.hex()}');
    return c;
  }

  /// API: passID.cancelChallenge
  /// Notifies server to discard previously requested [challenge].
  /// [SocketException] on connection errors.
  Future<void> cancelChallenge(ProtoChallenge challenge) async {
    _log.debug('passID.cancelChallenge(challenge=${challenge.data.hex()}) =>');
    try {
      await _transceive(method: 'cancelChallenge', params: challenge.toJson(), notify: true);
    } catch(e) {
      _log.warning('An exception was encountered while notifying server to cancel challenge.\n Error="$e"');
    }
  }

  /// API: passID.login
  /// Returns [Session] from server.
  /// Can throw [JRPClientError], [PassIdError] and [SocketException] on connection errors.
  Future<Session> login(UserId uid, CID cid, ChallengeSignature csig, { EfDG1 dg1 }) async {
    _log.debug('passID.login() =>');
    final params = {
      ...uid.toJson(),
      ...cid.toJson(),
      ...csig.toJson(),
      if(dg1 != null) 'dg1': dg1.toBytes().base64()
    };

    final resp = await _transceive(method: 'login', params: params);
    _throwIfError(resp);

    final s = Session.fromJson(resp, uid: uid);
    _log.debug('passID.login <= session= $s');
    return s;
  }

  /// API: passID.register
  /// Returns [Session] from server.
  /// Can throw [JRPClientError], [PassIdError] and [SocketException] on connection errors.
  Future<Session> register(final EfSOD sod, final EfDG15 dg15, final CID cid, final ChallengeSignature csig, {EfDG14 dg14}) async {
    _log.debug('passID.register() =>');
    final params = {
      'sod' : sod.toBytes().base64(),
      'dg15' : dg15.toBytes().base64(),
      ...cid.toJson(),
      ...csig.toJson(),
      if(dg14 != null) 'dg14': dg14.toBytes().base64()
    };

    final resp = await _transceive(method: 'register', params: params);
    _throwIfError(resp);

    final s = Session.fromJson(resp);
    _log.debug('passID.register <= session= $s');
    return s;
  }

  /// API: passID.sayHello
  /// Returns [String] greeting message from server.
  /// Can throw [JRPClientError], [PassIdError] and [SocketException] on connection errors.
  Future<String> sayHello(Session session) async {
    _log.debug('passID.sayHello() => session=$session');

    final mac = session.calculateMAC(apiName: 'sayHello', rawParams: session.uid.toBytes());
    final params = {
      ...session.uid.toJson(),
      ...mac.toJson()
    };

    final resp = await _transceive(method: 'sayHello', params: params);
    _throwIfError(resp);

    final srvMsg = resp["msg"] as String;
    _log.debug('passID.register <= srvMsg="$srvMsg"');
    return srvMsg;
  }

/******************************************** API CALLS END *************************************************/
/************************************************************************************************************/

  Future<dynamic> _transceive({ @required String method, dynamic params, bool notify = false }) {
    final apiMethod = _apiPrefix + method;
    return _rpc.call(method: apiMethod, params: params, notify: notify);
  }

  void _throwIfError(dynamic resp) {
    if(resp is JRpcError) {
      throw PassIdError(resp.code, resp.message);
    }
  }
}
