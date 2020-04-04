//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:dmrtd/extensions.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

import 'jrpc_objects.dart';


class JRPClientError implements Exception {
  String message;
  JRPClientError(this.message);
  @override
  String toString() => 'JRPClientError: $message';
}

/// Class represents JSON RPC client for sending
/// and receiving JSON RPC objects.
class JRPClient {
  JRpcVersion rpcVersion = JRpcVersion.v2;
  bool persistentConnection;
  HttpClient httpClient = HttpClient();
  String userAgent;
  String origin;
  Uri url;

  final _log = Logger("jrpc");

  /// Constructs new [JRPCClient] with server [url] and
  /// optional parameters:
  ///   [httpClient], http headers [origin] & [userAgetnt] and [persistentConnection]
  JRPClient(this.url,
      {this.httpClient,
      this.origin,
      this.userAgent,
      this.persistentConnection = true});

  /// Call the method on the server. Returns Future<null>
  void notify({@required final String method, final dynamic params}) {
    call(method: method, params: params, notify: true);
  }

  /// Invokes remote procedure [method] on the server with [params].
  /// Returns Future<dynamic>.
  /// If [notify] is true, procedure is invoked as notification and no data is returned.
  /// Returns the response.
  ///
  Future<dynamic> call({ @required final String method, final dynamic params = const [], notify = false }) async {
    final reqId = notify ? null : Uuid().v4(options: {'rng': UuidUtil.cryptoRNG});
    var req = JRpcRequest(method, params, reqId, version: rpcVersion);

    final resp  = await _sendRequest(req);
    final jresp = await _handleResonse(resp, reqNotify: notify);
    if (notify) {
      return Future.value(null);
    } else {
      return _handleJRpcResponse(reqId, jresp);
    }
  }

  Future<HttpClientResponse> _sendRequest(final JRpcRequest jrpcRequest) async {
    _log.debug('Sending rpc call to: ${url}');
    _log.debug('  rpc_version=${jrpcRequest.version}');
    _log.debug('  id=${jrpcRequest.id}');
    _log.debug("  method='${jrpcRequest.method}'");
    _log.deVerbose(' call params=${jrpcRequest.params}');
    String payload;
    try {
      payload = json.encode(jrpcRequest.toJson());
    } catch (e) {
      throw JRPClientError("Can't serialized package ($jrpcRequest) to JSON");
    }
    _log.deVerbose(' serialized payload=$payload');

    // Make a http POST request
    final request = await httpClient.postUrl(url);
    request.persistentConnection = persistentConnection;
    request.headers.add(HttpHeaders.acceptHeader, 'application/json');
    request.headers.add(HttpHeaders.contentTypeHeader, 'application/json');
    if (origin != null && origin.isNotEmpty) {
      request.headers.add('Origin', origin);
    }
    if (userAgent != null && userAgent.isNotEmpty) {
      request.headers.add(HttpHeaders.userAgentHeader, userAgent);
    }

    // Add json payload and send request
    request.write(payload);
    return request.close();
  }

  Future<dynamic> _handleResonse(final HttpClientResponse resp, {@required final reqNotify}) async {
    _log.debug('Received response with status code: ${resp.statusCode}');
    final content = await resp.transform(utf8.decoder).join();
    _log.deVerbose('Response content="$content"');

    if(reqNotify && (resp.statusCode == 204 || content.isEmpty)) {
      return null;
    }
    else if(resp.statusCode == 200) {
      try {
        final jrpcResp = JRpcResponse.parse(json.decode(content));
        _log.debug('RPC response for reqId=${jrpcResp.id}');
        if(jrpcResp.isError()) {
          _log.error('${jrpcResp.error}');
        }
        else {
          _log.deVerbose('RPC response data=${jrpcResp.result}');
        }
        return jrpcResp;
      }
      on Exception catch(e) {
        throw JRPClientError('Failed to parse RPC response: ${e}');
      }
    }
    throw JRPClientError('Request error: statusCode=${resp.statusCode} headers="${resp.headers}" content="${content}"');
  }

  dynamic _handleJRpcResponse(String reqId, JRpcResponse response) {
    assert(reqId == response.id);
    if(response.isError()) {
      return response.error;
    }
    return response.result;
  }
}