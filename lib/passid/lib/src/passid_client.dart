//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'dart:io';
import 'package:dmrtd/dmrtd.dart';
import 'package:logging/logging.dart';
import 'package:passid/src/proto/uid.dart';

import 'authn_data.dart';
import 'proto/passid_api.dart';
import 'proto/passid_error.dart';
import 'proto/proto_challenge.dart';
import 'proto/session.dart';


class PassIdClient {

  final _log = Logger('passid.client');
  final PassIdApi _api;
  ProtoChallenge _challenge;
  Session _session;
  Future<bool> Function(SocketException e) _onConnectionError;
  Future<bool> Function(EfDG1 dg1) _onDG1FileRequest;

  /// Returns connection timeout.
  Duration get timeout => _api.timeout;
  set timeout(Duration timeout) => _api.timeout = timeout;

  /// Returns [UserId] or [null]
  /// if session is not established yet.
  UserId get uid => _session?.uid;

  /// Returns server [Uri] url.
  Uri get url => _api.url;
  set url(Uri url) => _api.url = url;

  /// Constructs new [PassIdClient] using server [url] address and
  /// optionally [httpClient].
  PassIdClient(Uri url, {HttpClient httpClient}) :
    _api = PassIdApi(url, httpClient: httpClient ?? HttpClient());


  /// Callback invoked when sending request fails due to connection errors.
  /// If [callback] returns true the the client will retry to connect.
  set onConnectionError(Future<bool> Function(SocketException e) callback) =>
    _onConnectionError = callback;

  /// Callback invoked when signing up via login method and
  /// server requested DG1 file (data from MRZ) in order to establish login session.
  /// If [callback] returns true the DG1 file will be send to the server.
  set onDG1FileRequested(Future<bool> Function(EfDG1 dg1) callback) =>
    _onDG1FileRequest = callback;

  /// Notifies server to dispose session
  /// establishment challenge used for register/login.
  void disposeChallenge() {
    if(_challenge != null) {
       _api.cancelChallenge(_challenge);
      _resetChallenge();
    }
  }

  /// Establishes session by calling passID login API using [AuthnData] returned via [callback].
  /// [AuthnData] should have assigned fields: [csig], [sod] and
  /// [dg1] in case server request it.
  ///
  /// Note: If login fails due to server requested EF.DG1 file this request
  ///       is handled via callback [onDG1FileRequested]. If not [PassIdError] is thrown.
  ///
  /// Throws [SocketException] on connection error if not handled by [onConnectionError] callback.
  /// Throws [PassIdError] when required data returned by [callback] is missing or
  /// when provided data is invalid e.g. verification of challenge signature fails.
  Future<void> login(Future<AuthnData> Function(ProtoChallenge challenge) callback) async {
    await _retriableCall(_getNewChallenge);

    final data = await callback(_challenge);
    _throwIfMissingSessionData(data);

    final uid = UserId.fromDG15(data.dg15);
    _session = await _retriableCallEx((error) async {
      EfDG1 dg1;
      if(error != null) {
        if(!error.isDG1Required() || data.dg1 == null ||
           !(await _onDG1FileRequest?.call(data.dg1) ?? false)) {
          throw _RethrowPassidError(error);
        }
        dg1 = data.dg1;
      }
      return _api.login(uid, _challenge.id, data.csig, dg1: dg1);
    });

    _resetChallenge();
  }

  /// Calls pasID ping API with [number] and returns [pong] number.
  /// Throws [SocketException] on connection error if not handled by [onConnectionError] callback.
  Future<int> ping(int number) async {
    return _api.ping(number);
  }

  /// Establishes session by calling passID register API using [AuthnData] returned via [callback].
  /// [AuthnData] should have assigned fields: [dg15], [csig], [sod] and
  /// [dg14] if AA public key in [dg15] is of type [EC].
  ///
  /// Throws [SocketException] on connection error if not handled by [onConnectionError] callback.
  /// Throws [PassIdError] when required data returned by [callback] is missing or
  /// when provided data is invalid e.g. verification of challenge signature fails.
  Future<void> register(Future<AuthnData> Function(ProtoChallenge challenge) callback) async {
    await _retriableCall(_getNewChallenge);

    final data = await callback(_challenge);
    _throwIfMissingSessionData(data);
    if(data.sod == null) {
      throw throw PassIdError(-32602, 'Missing proto data to establish session');
    }

    _session = await _retriableCall(() =>
      _api.register(data.sod, data.dg15, _challenge.id, data.csig, dg14: data.dg14)
    );

    _resetChallenge();
  }

  /// Calls passID sayHello API and returns greeting from server.
  /// Session must be established prior calling this function via
  /// either [register] or [login] method.
  ///
  /// Throws [SocketException] on connection error if not handled by [onConnectionError] callback.
  /// Throws [PassIdError] if session is not set or
  /// invalid session parameters.
  Future<String> requestGreeting() {
    if(_session == null) {
      throw PassIdError(-32602, 'Session not established');
    }
    return _retriableCall(() =>
      _api.sayHello(_session)
    );
  }

  Future<void> _getNewChallenge() async {
    _challenge = await _api.getChallenge();
  }

  /// Function recursively calls [func] in case of a handled exception until result is returned.
  /// Unhandled exceptions are passed on.
  /// For example when there is connection error and callback [_onConnectionError]
  /// returns true to retry connecting.
  Future<T> _retriableCallEx<T> (Future<T> Function(PassIdError error) func, {PassIdError error}) async {
    try{
      return await func(error);
    }
    on _RethrowPassidError catch(e) {
      e.unwrapAndThrow();
    }
    on SocketException catch(e) {
      if(await _onConnectionError?.call(e) ?? false) {
        return await _retriableCallEx(func);
      }
      rethrow;
    }
    on PassIdError catch(e) {
      return _retriableCallEx(func, error: e);
    }
  }

  Future<T> _retriableCall<T> (Future<T> Function() func) async {
    return _retriableCallEx((error) {
      if(error != null) {
        throw _RethrowPassidError(error);
      }
      return func();
    });
  }

  void _resetChallenge() {
    _challenge = null;
  }

  /// Session data is data needed to establish PassID proto session
  /// e.g: dg15 (AA public key) and csig.
  void _throwIfMissingSessionData(final AuthnData data) {
    if(data.dg15 == null ||
      (data.dg15.aaPublicKey.type == AAPublicKeyType.EC && data.dg14 == null) ||
      data.csig == null || data.csig.isEmpty){
        throw PassIdError(-32602, 'Missing proto data to establish session');
    }
  }
}

/// Wrapper exception for PassIdError to
/// rethrow it in _retriableCallEx
class _RethrowPassidError {
  final PassIdError error;
  _RethrowPassidError(this.error);
  void unwrapAndThrow() {
    throw error;
  }
}