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

class StorageNode {
  String name;
  String host;
  bool isEncryptedEndpoint;
  int port;
  NetworkType networkType;
  String chainID;

  StorageNode(
      { @required this.name,
        @required this.host,
        @required this.port,
        @required this.isEncryptedEndpoint,
        @required this.networkType,
        this.chainID}) {

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
}

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
}

class StorageServerTemporary extends StorageServer{
  String accountID;
  String chainID;

  StorageServerTemporary(
      { @required name,
        @required host,
        @required port,
        @required isEncryptedEndpoint,
        @required accountID,
        chainID
      }) {
    //remove http(s) part of host
    this.host = this.host.toLowerCase();
    this.host = this.host.replaceFirst("https://", "");
    this.host = this.host.replaceFirst("http://", "");

    this.chainID = (chainID != null? chainID: null);
  }
}

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
class StorageData {
  StorageNode selectedNode;
  StorageNode defaultNode;
  List<StorageNode> _nodes;
  List<StepData> _steps;
  StorageServer storageServer;
  StorageServerTemporary _storageServerTemporary;

  DBAkeyStorage dbAkeyStorage;


  StorageData(){
    this._nodes = new List();
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
    // this._steps[2] =
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

  DBAkeyStorage getDBAkeyStorage(){
    return this.dbAkeyStorage;
  }



}

//singelton class
class Storage extends StorageData {
  static final Storage _singleton = new Storage._internal();

  factory Storage(){
    StorageData();
    return _singleton;
  }

  Storage._internal(){
    //initialization your logic here
  }
}
