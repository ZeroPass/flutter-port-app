//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'dart:convert' as con;

class JRpcObjectError implements Exception {
  final String message;
  JRpcObjectError(this.message);
  @override
  String toString() => 'JRpcObjectError: message';
}


enum JRpcVersion {
  v1,
  v2
}

/// JRpcRequest represents JSON-RPC Request object
class JRpcRequest {
  final String method;

  final dynamic params;

  final String id;
  final JRpcVersion version;

  JRpcRequest(this.method, this.params, this.id, {this.version = JRpcVersion.v2}) {
    if(version == JRpcVersion.v1 && params is Map) {
      throw JRpcObjectError("JSON-RPC 1.0 doesn't support named params");
    }
  }

  bool isNotification() => id == null || id.isEmpty;

  /// Returns JSON map.
   Map<String, dynamic> toJson() {
    Map<String, dynamic> json;
    switch (version) {
      case JRpcVersion.v1:
        json = {
          'method': method,
          'id': id
        };
        break;
      case JRpcVersion.v2:
        json = {
          'jsonrpc': '2.0',
          'method': method
        };
        if (!isNotification()){
          json['id'] = id;
        }
        break;
    }

    if(params != null) {
      json['params'] = (params is List || params is Map) ? params : [params];
    }
    return json;
  }

  @override
  String toString() => 'JRpcRequest: ${toJson()}';
}


class JRpcError implements Exception {
  final int code;
  final String message;
  final dynamic data;
  const JRpcError(this.code, this.message, {this.data});

  Map<String, dynamic> toJson() {
    return {
      'code' : code,
      'message' : message,
      'data' : data
    };
  }

  @override
  String toString() => "JRpcError: code=$code message='$message' data=$data";
}


/// JRpcRequest represents JSON-RPC Response object
class JRpcResponse {

  final String id;
  final JRpcVersion version;
  final dynamic result;
  final JRpcError error;

  JRpcResponse(this.id, {this.result, this.error, this.version = JRpcVersion.v2}) {
    assert(result != null || error != null);
  }

  bool isError() => error != null;

  factory JRpcResponse.parse(Map<String, dynamic> json) {
    var version = JRpcVersion.v1;
    if(json.containsKey('jsonrpc')) {
      if(json['jsonrpc'] != '2.0'){
        throw JRpcObjectError("Error parsing response: expected jsonrpc = 2.0, found: ${json['jsonrpc']}");
      }
      version = JRpcVersion.v2;
    }

    var id;
    if(json['id'] is int) {
      id = (json['id'] as int).toRadixString(10);
    }
    else {
      id = json['id'] as String;
    }

    if(json.containsKey('error')) {
      final error = json['error'] as Map<String, dynamic>;
      final code = error['code'] as int;
      final msg  = error['message'] as String;
      dynamic data;
      if(error.containsKey('data')) {
        data = error['data'];
      }
      return JRpcResponse(id, version: version, error: JRpcError(code, msg, data: data));
    }
    return JRpcResponse(id, version: version, result: json['result']);
  }

  /// Returns JSON map.
   Map<String, dynamic> toJson() {
    final json =({
      'id': id,
    });

    if(version == JRpcVersion.v2) {
      json['jsonrpc'] = '2.0';
    }

    if(result != null) {
      json['result'] = result;
    }
    else {
      json['error'] = con.json.encode(error.toJson());
    }
    return json;
  }

  @override
  String toString() => 'JRpcRequest: ${toJson()}';
}