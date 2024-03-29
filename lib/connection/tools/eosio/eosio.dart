import 'dart:async';

import 'package:dmrtd/extensions.dart';
//import 'package:eosdart/eosdart.dart';
import 'package:eosdart/eosdart.dart';
import 'package:eosio_port_mobile_app/connection/connection.dart';
import 'package:eosio_port_mobile_app/utils/storage.dart';
import 'package:eosio_port_mobile_app/utils/structure.dart';
import 'dart:collection';
import 'package:logging/logging.dart';

enum EosioVersion { v1, v2 }

class EosioException implements Exception {
  // Possible Eosio Exception error codes
  static const int ecGeneralError               = 400;


  // Predefined Port errors
  static const unknownEndpoint         = EosioException.conflict('Cannot reach endpoint');

  final int code;
  final String message;
  const EosioException(this.code, this.message);

  const EosioException.conflict(String error) : this(ecGeneralError, error);

  @override
  bool operator == (covariant EosioException other) {
    return code == other.code && message == other.message;
  }

  @override
  String toString() => 'PortError(code=$code, error=$message)';
}



class PushTrxResponse{
  bool _isValid;
  String? _data;
  String? _error;

  PushTrxResponse(this._isValid, [this._data, this._error]);

  bool get isValid => _isValid;

  set isValid(bool value) {
    _isValid = value;
  }

  get data => _data;

  set data(value) {
    _data = value;
  }

  get error => _error;

  set error(value) {
    _error = value;
  }
}

class PrivateKey{
  final _log = Logger("Private key");
  String privateKey;

  PrivateKey(this.privateKey) {
    //you can put here any restrictions (length, type, etc)
  }

  String get(){
    return privateKey;
  }

}

class Keys extends ListBase<PrivateKey>{
  List<PrivateKey> _list;

  Keys() : _list = new List.empty(growable: true);

  void set length(int l) {
    this._list.length=l;
  }

  int get length => _list.length;

  PrivateKey operator [](int index) => _list[index];

  void operator []=(int index, PrivateKey value) {
    _list[index]=value;
  }

  List<String> listWithStr(){
    List<String> listStr = List<String>.empty(growable: true);
    _list.forEach((element) {listStr.add(element.get());});
    return listStr;
  }

  Iterable<PrivateKey> myFilter(text) => _list.where( (PrivateKey e) => e.privateKey != null);

}

class Eosio{
  final _log = Logger("connection.Eosio");

  late EOSClient _eosClient;
  late int connectionRetryMax;

  Eosio({required NodeServer storageNode, required EosioVersion version, required Keys privateKeys, int httpTimeout = 15, this.connectionRetryMax = 3}) {
    assert(storageNode != null);
    assert(privateKeys.length > 0);

    _eosClient =  EOSClient(storageNode.toString(), StringUtil.getWithoutTypeName(version),
        privateKeys: privateKeys.listWithStr(),
        httpTimeout: httpTimeout);
  }

  Future<dynamic> onError ({required String functionName, required dynamic e}){
    _log.log(Level.FINE, "Error in '$functionName':" + e.toString());
    return Future.value({'isValid': false, 'exp': e.toString()});
  }

  APIresponse onErrorAttemptsExceeded ({required String functionName, required dynamic e}){
    _log.log(Level.FINE, "Error in '$functionName'. Exceeded connection attempts. Error:" + e.toString());
    return APIresponse(false, text:  e.toString());
  }

  void onErrorRetry ({required String functionName, required retryCounter}){
    _log.log(Level.FINE, "Error in '$functionName'. Retry conunter: $retryCounter");
  }

  Future<PushTrxResponse> onErrorTrx ({required String functionName, required dynamic e}){
    _log.log(Level.FINE, "Error in '$functionName':" + e.toString());
    return Future.value(PushTrxResponse(false, null, e.toString()));
  }

  Future<APIresponse> getNodeInfo({int connectionRetryCounter = 0}) async{
    try
    {
      _log.log(Level.INFO, "Get node info.");
      var response = await _eosClient.getInfo();
      return APIresponse(true,code: 200, data: response.toString());
    }
    catch(e){
      if (connectionRetryCounter < connectionRetryMax) {
        connectionRetryCounter ++;
        onErrorRetry(functionName: "getNodeInfo", retryCounter: connectionRetryCounter);
        return await getNodeInfo(connectionRetryCounter: connectionRetryCounter);
      }
      return onErrorAttemptsExceeded(functionName: "getNodeInfo", e: e);
    }
  }

  Future<dynamic> getAccountInfo({required String account}) async{
    try
    {
      _log.log(Level.INFO, "Get account info: $account");
      return await _eosClient.getAccount(account);
    }
    catch(e){ return onError(functionName: "getAccountInfo", e: e);}
  }

  Future<APIresponse> getTableRows({required String code, required String scope, required String table,
    bool json = true,
    String tableKey = '',
    String lower = '',
    String upper = '',
    int indexPosition = 1,
    String keyType = '',
    bool reverse = false,
    int connectionRetryCounter = 0
  }) async{
    try
    {
      _log.log(Level.INFO, "GetTableRows {code: $code, scope:$scope, table:$table,"
          "json:$json, tableKey:$tableKey, lower:$lower, upper:$upper,"
          "index position: $indexPosition, key type: $keyType, reverse: $reverse}");

      assert(code != null && code != "");
      assert(scope != null && scope != "");
      assert(table != null && table != "");

      //https://developers.eos.io/manuals/eos/latest/nodeos/plugins/chain_api_plugin/api-reference/index#operation/get_table_rows
      //return Map<String, dynamic> ();

      var response = await _eosClient.getTableRow(code, scope, table,
                                                  json: json,
                                                  tableKey: tableKey,
                                                  lower: lower,
                                                  upper: upper,
                                                  indexPosition: indexPosition,
                                                  keyType: keyType,
                                                  reverse: reverse);

      return APIresponse(true,code: 200, data: response);
    }
    catch(e){
      if (connectionRetryCounter < connectionRetryMax) {
        connectionRetryCounter ++;
        onErrorRetry(functionName: "getTableRows", retryCounter: connectionRetryCounter);
        return await getTableRows(code: code, scope: scope, table: table, connectionRetryCounter: connectionRetryCounter);
      }
      return onErrorAttemptsExceeded(functionName: "getTableRows", e: e);
    }
  }


  /// Function recursively calls [func] in case of a handled exception until result is returned.
  /// Unhandled exceptions are passed on.
  /// For example when there is connection error and callback [_onConnectionError]
  /// returns true to retry connecting.
  Future<T> _retriableCallEx<T> (Future<T> Function(EosioException? error) func, {EosioException? error}) async {
    try{
      return await func(error);
    }
    on EosioException catch(e) {
      return await _retriableCallEx(func);
    }
  }

  Future<T> _retriableCall<T> (Future<T> Function() func) async {
    return _retriableCallEx((error) {
      if(error != null) {
        throw _RethrowPortError(error);
      }
      return func();
    });
  }


  static Authorization createAuth({required String actor, required String permission}){
    Logger("eosio;Authorization;createAuth").log(Level.FINER, "{actor:$actor, permission:$permission}");
    assert(actor != null && actor != "");
    assert(permission != null && permission != "");

    Authorization item = Authorization();
    item.actor = actor;
    item.permission = permission;
    return item;
  }

  static List<Authorization> createAuthList({required List<String> actors, required List<String> permissions}){
    assert(actors != null && actors.length > 0);
    assert(permissions != null && permissions.length > 0);
    assert(actors.length == permissions.length);

    List<Authorization> auths = new List<Authorization>.empty(growable: true);
    for(var i = 0; i<actors.length; i++){
      auths.add(createAuth(actor: actors[i], permission: permissions[i]));
    }

    return auths;
  }

  static bool checkData({required Map data}){
    Logger("eosio;checkData").log(Level.FINER, "{data:$data}");
    assert (data != null);

    bool isValid = true;
    data.forEach((k, v) {
      Logger("eosio;checkData").verbose("Key: $k; value: $v");
      if (k == null || v == null) isValid = false;
    });
    Logger("eosio;checkData").log(Level.FINER, "{isValid:$isValid}");
    return isValid;
  }

  Future<PushTrxResponse> pushTransaction({required String code, required String actionName, required List<Authorization> auth, required Map data})async {
    try {
      _log.log(
          Level.INFO, "Push transaction {code: $code, action name: $actionName,"
          "auth: ${auth.toString()}, data: ${data.toString()}}");

      List<Action> actions = [
        Action()
          ..account = code
          ..name = actionName
          ..authorization = auth
          ..data = data
      ];
      Transaction transaction = Transaction()..actions = actions;
      var trx = await _eosClient.pushTransaction(transaction, broadcast: true);
      return PushTrxResponse(true, trx);
    }
    catch(e){ return onErrorTrx(functionName: "pushTransaction", e: e);}
  }
}
/// Wrapper exception for PortError to
/// rethrow it in _retriableCallEx
class _RethrowPortError {
  final EosioException error;
  _RethrowPortError(this.error);
  Never unwrapAndThrow() {
    throw error;
  }
}