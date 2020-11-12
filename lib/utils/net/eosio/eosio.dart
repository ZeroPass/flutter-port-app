import 'dart:async';

import 'package:eosdart/eosdart.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/utils/structure.dart';
import 'dart:collection';
import 'package:logging/logging.dart';

enum EosioVersion { v1, v2 }

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
class test{}

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

  Iterable<PrivateKey> myFilter(text) => _list.where( (PrivateKey e) => e.privateKey != null);

}

class Eosio{
  final _log = Logger("Eosio");

  EOSClient _eosClient;

  Eosio(StorageNode storageNode, EosioVersion version, Keys privateKeys, {int httpTimeout = 15}) {
    assert(storageNode != null);
    assert(privateKeys.length > 0);

    _eosClient =  EOSClient(/*storageNode.toString()*/"https://jungle2.cryptolions.io:443", StringUtil.getWithoutTypeName(version), httpTimeout: httpTimeout);
  }

  Future<dynamic> onError (String functionName,e){
    _log.log(Level.FINE, "Error in '$functionName':" + e.toString());
    return null;
  }

  Future<NodeInfo> getNodeInfo() async{
    try
    {
      _log.log(Level.INFO, "Get node info.");
      await _eosClient.getInfo().then((NodeInfo nodeInfo) {
        return nodeInfo;
      }).catchError ((e) { return onError("getNodeInfo", e); });
    }
    catch(e){ return onError("getNodeInfo", e);}
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
      await _eosClient.getTableRow(code, scope, table,
      json: json,
      tableKey: tableKey,
      lower: lower,
      upper: upper,
      indexPosition: indexPosition,
      keyType: keyType,
      reverse: reverse).then((Map<String, dynamic> rows) {
        print (rows);
        //Type type = rows.runtimeType;
        print(rows.runtimeType);
        return Future.value(rows);
      }).catchError ((e) {
        return onError("getTableRows", e); });
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
      if (k == null || v == null) isValid = false;
    });
    return isValid;
  }

  Future<void> pushTransaction(String code, String actionName, List<Authorization> auth, Map data)async {
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
      _eosClient.pushTransaction(transaction, broadcast: true).then((trx) {
        print(trx);
      }).catchError ((e) => onError("getTableRows", e));
    }
    catch(e){ onError("pushTransaction", e);}
  }

}