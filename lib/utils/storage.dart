import 'package:eosio_passid_mobile_app/screen/flushbar.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart';
import 'package:dmrtd/src/extension/string_apis.dart';
import 'package:dmrtd/src/extension/datetime_apis.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:eosio_passid_mobile_app/settings/settings.dart';
import 'package:dmrtd/src/proto/dba_keys.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:eosio_passid_mobile_app/utils/storageSave.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


/*
 * StorageNode
 */

@JsonSerializable(nullable: false)
class StorageNode {
  String name;
  String host;
  bool isEncryptedEndpoint;
  int port;
  NetworkType networkType;
  String chainID;
  bool notBlockchain;
  //do not need to be stored - just to check if field is correct in settings section
  Map<String, Map<String, dynamic>> validation;

  StorageNode(
      { @required this.name,
        @required this.host,
        @required this.port,
        @required this.isEncryptedEndpoint,
        @required this.networkType,
        this.chainID,
        this.notBlockchain = false
      }) {

        //remove http(s) part of host
        this.host = this.host.toLowerCase();
        this.host = this.host.replaceFirst("https://", "");
        this.host = this.host.replaceFirst("http://", "");

        //use chainID from settings if user not declare it in the call
        if (this.chainID == null) {
          if (settings["chain_id"][this.networkType] == null)
            throw new FormatException("Chain id is not defined");
          this.chainID = settings["chain_id"][this.networkType];
        }
  }

  StorageNode.clone(StorageNode storageNode):
        this(name: storageNode.name,
          host:storageNode.host,
          port:storageNode.port,
          isEncryptedEndpoint: storageNode.isEncryptedEndpoint,
          networkType: storageNode.networkType,
          chainID: storageNode.chainID,
          notBlockchain: storageNode.notBlockchain);

  StorageNode clone(StorageNode storageNode){
    this.name = storageNode.name;
    this.port = storageNode.port;
    this.isEncryptedEndpoint = storageNode.isEncryptedEndpoint;
    this.networkType = storageNode.networkType;
    this.chainID = storageNode.chainID;
    this.notBlockchain = storageNode.notBlockchain;
  }

  bool compare(StorageNode storageNode)
  {
    return (this.name == storageNode.name &&
        this.host == storageNode.host &&
        this.port == storageNode.port &&
        this.isEncryptedEndpoint == storageNode.isEncryptedEndpoint &&
        this.networkType == storageNode.networkType &&
        this.chainID == storageNode.chainID &&
        this.notBlockchain == storageNode.notBlockchain)?
      true:false;
  }

  Map<String, dynamic> fillValidationUnit(String name)
  {
    Map<String, dynamic> structure ={
      'isValid': true,
      'errorMsg': null
    };
    return structure;
  }

  void initValidation()
  {
    validation = new Map();
    //init validation values on true
    validation['name'] = fillValidationUnit('name');
    validation['host'] = fillValidationUnit('host');
    validation['isEncryptedEndpoint'] = fillValidationUnit('isEncryptedEndpoint');
    validation['port'] = fillValidationUnit('port');
    validation['networkType'] = fillValidationUnit('networkType');
    validation['chainID'] = fillValidationUnit('chainID');
    validation['notBlockchain'] = fillValidationUnit('notBlockchain');
  }

  void setValidationError(String field, String errorMsg)
  {
    if (this.validation.containsKey(field))
    {
      this.validation[field]['isValid'] = false;
      this.validation[field]['errorMsg'] = errorMsg;
    }
  }

  void setValidationCorrect(String field)
  {
    if (this.validation.containsKey(field) && !this.validation[field]['isValid'])
    {
      this.validation[field]['isValid'] = true;
      this.validation[field]['errorMsg'] = null;
    }
  }

  factory StorageNode.fromJson(Map<String, dynamic> json) => _$StorageNodeFromJson(json);
  Map<String, dynamic> toJson() => _$StorageNodeToJson(this);

  static int hasEncryptedEndpoint(String host){
    if (host.toLowerCase().contains("https://")) return 1;//encrypted endpoint
    else if (host.toLowerCase().contains("http://")) return 0;//not encrypted endpoint
    else return 2;//no http(s) beginning of string
  }

  String toString(){
    String prefix = (this.isEncryptedEndpoint)? "https://" : "http://";
    String port = (this.port != null)? ":"+ this.port.toString() : "";
    return prefix + this.host + port;
  }

  String url()
  {
    String prefix = (this.isEncryptedEndpoint)? "https://" : "http://";
    String port = (this.port != null)? ":"+ this.port.toString() : "";
    return prefix + this.host + port;
  }
}

StorageNode _$StorageNodeFromJson(Map<String, dynamic> json) {
  return StorageNode(
    name: json['name'] as String,
    host: json['host'] as String,
    isEncryptedEndpoint: json['isEncryptedEndpoint'] as bool,
    port: json['port'] as int,
    networkType: getNetworkTypeFromString(json['networkType']),
    chainID: json['chainID'] as String,
    notBlockchain: json['notBlockchain'] as bool
  );
}

Map<String, dynamic> _$StorageNodeToJson(StorageNode instance) => <String, dynamic>{
  'name': instance.name,
  'host': instance.host,
  'isEncryptedEndpoint': instance.isEncryptedEndpoint,
  'port': instance.port,
  'networkType': instance.networkType.toString(),
  'chainID': instance.chainID,
  'notBlockchain': instance.notBlockchain
};



/*
 * StorageServer
 */
@JsonSerializable()
class StorageServer {
  String name;
  String host;
  bool isEncryptedEndpoint;
  int port;
  int timeoutInSeconds;

  StorageServer(
      { @required this.name,
        @required this.host,
        @required this.port,
        @required this.isEncryptedEndpoint,
        this.timeoutInSeconds = 5
        }) {
    //remove http(s) part of host
    this.host = this.host.toLowerCase();
    this.host = this.host.replaceFirst("https://", "");
    this.host = this.host.replaceFirst("http://", "");
  }

  static int hasEncryptedEndpoint(String host){
    if (host.toLowerCase().contains("https://")) return 1;//encrypted endpoint
    else if (host.toLowerCase().contains("http://")) return 0;//not encrypted endpoint
    else return 2;//no http(s) beginning of string
  }

  //print url address
  String toString(){
    String prefix = (this.isEncryptedEndpoint)? "https://" : "http://";
    String port = (this.port != null)? ":"+ this.port.toString() : "";
    return prefix + this.host + port;
  }

  factory StorageServer.fromJson(Map<String, dynamic> json) => _$StorageServerFromJson(json);
  Map<String, dynamic> toJson() => _$StorageServerToJson(this);
}

StorageServer _$StorageServerFromJson(Map<String, dynamic> json) {
  return StorageServer(
    name: json['name'] as String,
    host: json['host'] as String,
    isEncryptedEndpoint: json['isEncryptedEndpoint'] as bool,
    port: json['port'] as int,
    timeoutInSeconds: json['timeoutInSeconds'] as int,
  );
}

Map<String, dynamic> _$StorageServerToJson(StorageServer instance) => <String, dynamic>{
  'name': instance.name,
  'host': instance.host,
  'isEncryptedEndpoint': instance.isEncryptedEndpoint,
  'port': instance.port,
  'timeoutInSeconds': instance.timeoutInSeconds,
};



/*
 * StorageServerTemporary
 */
@JsonSerializable()
class StorageServerTemporary extends StorageServer{
  String accountID;
  String chainID;

  StorageServerTemporary(
      { @required name,
        @required host,
        @required port,
        @required isEncryptedEndpoint,
        @required timeoutInSeconds,
        @required accountID,
        chainID
      }) {
    //remove http(s) part of host
    this.host = this.host.toLowerCase();
    this.host = this.host.replaceFirst("https://", "");
    this.host = this.host.replaceFirst("http://", "");

    this.chainID = (chainID != null? chainID: null);
  }

  factory StorageServerTemporary.fromJson(Map<String, dynamic> json) => _$StorageServerTemporaryFromJson(json);
  Map<String, dynamic> toJson() => _$StorageServerTemporaryToJson(this);
}

StorageServer _$StorageServerTemporaryFromJson(Map<String, dynamic> json) {
  return StorageServerTemporary(
    name: json['name'] as String,
    host: json['host'] as String,
    isEncryptedEndpoint: json['isEncryptedEndpoint'] as bool,
    port: json['port'] as int,
    timeoutInSeconds: json['timeoutInSeconds'] as int,
    accountID: json['accountID'] as String,
    chainID: json['chainID'] as String,
  );
}

Map<String, dynamic> _$StorageServerTemporaryToJson(StorageServerTemporary instance) => <String, dynamic>{
  'name': instance.name,
  'host': instance.host,
  'isEncryptedEndpoint': instance.isEncryptedEndpoint,
  'port': instance.port,
  'timeoutInSeconds': instance.timeoutInSeconds,
  'accountID': instance.accountID,
  'chainID': instance.chainID,
};


class DBAkeyStorage {
  static SharedPreferences prefs;

  void init() async{
    if(prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }
  }

  DBAKeys getDBAKeys() {
    final data = prefs.getString("dbaKeys");
    if(data == null) {
      return null;
    }
    final jkeys = jsonDecode(data);
    return DBAKeys(
        jkeys['mrtd_num'],
        (jkeys['dob'] as String).parseDateYYMMDD(),
        (jkeys['doe'] as String).parseDateYYMMDD()
    );
  }

  Future<bool> setDBAKeys(final DBAKeys keys) {
    final data = jsonEncode({
      'mrtd_num' : keys.mrtdNumber,
      'dob'      : keys.dateOfBirth.formatYYMMDD(),
      'doe'      : keys.dateOfExpiry.formatYYMMDD()
    });
    return prefs.setString("dbaKeys", data);
  }

}


int _NUM_OF_STEPS = 3;
//data stored in the singleton class
@JsonSerializable()
class StorageData {
  bool _isUpdatedInCurrentSession;
  bool _loggingEnabled;
  StorageNode selectedNode;
  StorageNode defaultNode;
  List<StorageNode> _nodes;
  List<StepData> _steps;
  StorageServer storageServer;
  StorageServerTemporary _storageServerTemporary;


  //this should not be stored on disc
  DBAkeyStorage dbAkeyStorage;


  StorageData(){
    this._nodes = new List();
    this._isUpdatedInCurrentSession = false;
    this._loggingEnabled = false;
    this.selectedNode = null;
    this.defaultNode = null;
    this.storageServer = null;
    this._storageServerTemporary = null;

    this.dbAkeyStorage = DBAkeyStorage();
    this.dbAkeyStorage.init();

    this._steps = new List(_NUM_OF_STEPS);
    //initialize every step
    this._steps[0] = StepDataEnterAccount();
    this._steps[1] = StepDataScan();
    this._steps[2] = StepDataAttestation();

  }

  bool get isUpdatedInCurrentSession => _isUpdatedInCurrentSession;

  set isUpdatedInCurrentSession(bool value) {
    _isUpdatedInCurrentSession = value;
  }

  void fromStorageData(StorageData item){
    this._loggingEnabled = item._loggingEnabled;
    this.selectedNode = item.selectedNode;
    this.defaultNode = item.defaultNode;
    this._nodes = item._nodes;
    this._steps = item._steps;
    this.storageServer = item.storageServer;
    this._storageServerTemporary = item._storageServerTemporary;

    //updated in current session
    this._isUpdatedInCurrentSession = item.isUpdatedInCurrentSession;
  }

  StorageData StorageDataDB({bool loggingEnabled, StorageNode selectedNode, StorageNode defaultNode, List<StorageNode> nodes, List<StepData> steps, StorageServer storageServer, StorageServerTemporary storageServerTemporary}){
    this._loggingEnabled = loggingEnabled;
    this.selectedNode = selectedNode;
    this.defaultNode = defaultNode;
    this._nodes = nodes;
    this._steps = steps;
    this.storageServer = storageServer;
    this._storageServerTemporary = storageServerTemporary;

    //updated in current session
    this._isUpdatedInCurrentSession = true;
    return this;
  }

  bool get loggingEnabled => _loggingEnabled;

  set loggingEnabled(bool value) {
    _loggingEnabled = value;
  }

  StorageNode getNode(){
    StorageNode defaultNode = this.getDefaultNode();
    StorageNode selectedNode = this.getSelectedNode();
    return selectedNode != null? selectedNode : defaultNode;
  }


  List<StepData> getStorageDataAll(){
    return _steps;
  }

  StepData getStorageData(int index){
    //out of array
    if (index > _NUM_OF_STEPS)
      return null;

    return _steps[index];
  }

  //add so storage list
  void addStorageNode(StorageNode sn){
    this._nodes.add(sn);
  }

  //get list of nodes stored in storage; you can also filter by network type
  List<StorageNode> storageNodes({networkType = null})
  {
    if (networkType == null)
      return this._nodes;

    List<StorageNode> selected = new List();
    for (var item in this._nodes)
      if (item.networkType == networkType)
        selected.add(item);
    return selected;
  }

  StorageNode getSelectedNode(){
    return this.selectedNode;
  }

  StorageNode getDefaultNode(){
    return this.defaultNode;
  }

  StorageServer getStorageServer(){
    return this.storageServer;
  }

  StorageServer getStorageServerTemporary(){
    return this._storageServerTemporary;
  }

  DBAkeyStorage getDBAkeyStorage(){
    return this.dbAkeyStorage;
  }

  factory StorageData.fromJson(Map<String, dynamic> json) => _$StorageDataFromJson(json);
  Map<String, dynamic> toJson() => _$StorageDataToJson(this);

  //save to local storage
  void save ({Function callback(bool) = null}) async{
    try {
      Map<String, dynamic> value = this.toJson();
      String forStorage =  json.encode(value);// value.toString();
      final storage = new FlutterSecureStorage();
      await storage.write(key: "data", value: forStorage);
      if (callback != null)
        callback(true);
    }
    catch(e){
      print(e);
      callback(false);
    }
  }
  void load({Function (bool isAlreadyUpdated, bool isValid, {String exc}) callback}) async{
    try{
      Storage storage = Storage();
      if (storage.isUpdatedInCurrentSession) {
        if (callback != null)
          callback(true, false);
        return;
      }
      final storageDB = new FlutterSecureStorage();
      //await storageDB.readAll();//just to await when you run a script first time
      String value = await storageDB.read(key: "data");
      storage.fromStorageData(StorageData.fromJson(jsonDecode(value)));
      if (callback != null)
        callback(false, true);
    }
    catch (e)  {
      if (callback != null)
        callback(true, false, exc: e.toString());
    }
  }
}

 StepDataListfromJson (Map<String, dynamic> list){
  List<StepData> output = new List();
  output.add(StepDataEnterAccount.fromJson(list['StepDataEnterAccount']));
  output.add(StepDataScan.fromJson(list['StepDataScan']));
  output.add(StepDataAttestation.fromJson(list['StepDataAttestation']));
  return output;
}


Map<String, dynamic> StepDataListToJson (List<StepData> list){
  Map<String, dynamic> output = new Map();
  output['StepDataEnterAccount'] = (list[0] as StepDataEnterAccount).toJson();
  output['StepDataScan'] = (list[1] as StepDataScan).toJson();
  output['StepDataAttestation'] = (list[2] as StepDataAttestation).toJson();
  return output;
}

StorageData _$StorageDataFromJson(Map<String, dynamic> json) {
  StorageData storageData = StorageData();
  return storageData.StorageDataDB(
    loggingEnabled: json['loggingEnabled'],
    selectedNode: StorageNode.fromJson(json['selectedNode']) as StorageNode,
    defaultNode: StorageNode.fromJson(json['defaultNode']),
    nodes: json['nodes'] != null ? (json['nodes'] as List).map(
            (e) =>StorageNode.fromJson(e as Map<String, dynamic>)).toList() : null,
    steps: StepDataListfromJson(json['steps']),
    storageServer: StorageServer.fromJson(json['storageServer']),
    storageServerTemporary: json['storageServerTemporary'] != null ? StorageServerTemporary.fromJson(json['storageServerTemporary']) : null,
  );
}

Map<String, dynamic> _$StorageDataToJson(StorageData instance) => <String, dynamic>{
  'loggingEnabled' : instance._loggingEnabled,
  'selectedNode': instance.selectedNode.toJson(),
  'defaultNode': instance.defaultNode.toJson(),
  'nodes': instance.storageNodes() != null?
            instance.storageNodes().map((item) => item.toJson()).toList() : null,
  'steps': StepDataListToJson(instance.getStorageDataAll()),
  'storageServer': instance.storageServer.toJson(),
  'storageServerTemporary': instance.getStorageServerTemporary()!= null ?
  instance.getStorageServerTemporary().toJson(): null
};

//singelton class
class Storage extends StorageData {
  static Storage _singleton = new Storage._internal();

  factory Storage(){
    StorageData();
    return _singleton;
  }

  Storage._internal(){}
}
