import 'dart:async';

import 'package:eosdart/eosdart.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/utils/structure.dart';
import 'dart:collection';
import 'package:logging/logging.dart';
import 'package:dmrtd/src/extension/logging_apis.dart';

enum EosioVersion { v1, v2 }

class PushTrxResponse{
  bool _isValid;
  var _data;
  var _error;

  PushTrxResponse(this._isValid, [this._data = null, this._error = null]);

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
    if (this.privateKey == null)
      throw FormatException("Private key must be valid - not null.");
  }
  String get(){
    return privateKey;
  }

}

class Keys extends ListBase<PrivateKey>{
  List<PrivateKey> _list;

  Keys() : _list = new List();


  void set length(int l) {
    this._list.length=l;
  }

  int get length => _list.length;

  PrivateKey operator [](int index) => _list[index];

  void operator []=(int index, PrivateKey value) {
    _list[index]=value;
  }

  List<String> listWithStr(){
    List<String> listStr = List<String>();
    _list.forEach((element) {listStr.add(element.get());});
    return listStr;
  }

  Iterable<PrivateKey> myFilter(text) => _list.where( (PrivateKey e) => e.privateKey != null);

}

class Eosio{
  final _log = Logger("Eosio");

  EOSClient _eosClient;

  Eosio(NodeServer storageNode, EosioVersion version, Keys privateKeys, {int httpTimeout = 15}) {
    assert(storageNode != null);
    assert(privateKeys.length > 0);

    _eosClient =  EOSClient(storageNode.toString(), StringUtil.getWithoutTypeName(version),
        privateKeys: privateKeys.listWithStr(),
        httpTimeout: httpTimeout);
  }

  Future<dynamic> onError (String functionName,e){
    _log.log(Level.FINE, "Error in '$functionName':" + e.toString());
    return null;
  }

  Future<PushTrxResponse> onErrorTrx (String functionName,e){
    _log.log(Level.FINE, "Error in '$functionName':" + e.toString());
    return Future.value(PushTrxResponse(false, null, e.toString()));
  }

  Future<NodeInfo> getNodeInfo() async{
    try
    {
      _log.log(Level.INFO, "Get node info.");
      return await _eosClient.getInfo();
    }
    catch(e){ return onError("getNodeInfo", e);}
  }

  Future<Account> getAccountInfo(String account) async{
    try
    {
      _log.log(Level.INFO, "Get account info: $account");
      return await _eosClient.getAccount(account);
    }
    catch(e){ return onError("getAccountInfo", e);}
  }

  Future<Map<String, dynamic>> getTableRows(String code, String scope, String table, {
    bool json = true,
    String tableKey = '',
    String lower = '',
    String upper = '',
    int indexPosition = 1,
    String keyType = '',
    bool reverse = false,
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
      return await _eosClient.getTableRow(code, scope, table,
                                                  json: json,
                                                  tableKey: tableKey,
                                                  lower: lower,
                                                  upper: upper,
                                                  indexPosition: indexPosition,
                                                  keyType: keyType,
                                                  reverse: reverse);
    }
    catch(e){
      return onError("getTableRows", e);
    }
  }

  static Authorization createAuth(String actor, String permission){
    Logger("eosio;Authorization;createAuth").log(Level.FINER, "{actor:$actor, permission:$permission}");
    assert(actor != null && actor != "");
    assert(permission != null && permission != "");

    Authorization item = Authorization();
    item.actor = actor;
    item.permission = permission;
    return item;
  }

  static List<Authorization> createAuthList(List<String> actors, List<String> permissions){
    assert(actors != null && actors.length > 0);
    assert(permissions != null && permissions.length > 0);
    assert(actors.length == permissions.length);

    List<Authorization> auths = new List<Authorization>();
    for(var i = 0; i<actors.length; i++){
      auths.add(createAuth(actors[i], permissions[i]));
    }

    return auths;
  }

  static bool checkData(Map data){
    Logger("eosio;checkData").log(Level.FINER, "{data:$data}");
    assert (data != null);

    bool isValid = true;
    data.forEach((k, v) {
      Logger("eosio;checkData").deVerbose("Key: $k; value: $v");
      if (k == null || v == null) isValid = false;
    });
    Logger("eosio;checkData").log(Level.FINER, "{isValid:$isValid}");
    return isValid;
  }

  Future<PushTrxResponse> pushTransaction(String code, String actionName, List<Authorization> auth, Map data)async {
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
    catch(e){ return onErrorTrx("pushTransaction", e);}
  }

}