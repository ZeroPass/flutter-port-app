import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart';
import 'package:dmrtd/src/extension/string_apis.dart';
import 'package:dmrtd/src/extension/datetime_apis.dart';
import 'package:eosio_passid_mobile_app/utils/structure.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:eosio_passid_mobile_app/constants/constants.dart';
import 'package:dmrtd/src/proto/dba_keys.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:eosio_passid_mobile_app/constants/constants.dart';
import 'package:logging/logging.dart';
import 'package:dmrtd/src/extension/logging_apis.dart';

/*
 * Server
 */
@JsonSerializable(nullable: false)
class Server {
  late Uri host;
  late int timeoutInSeconds;

  //do not need to be stored - just to check if field is correct in settings section
  late Map<String, Map<String, dynamic>> validation;

  Server({
    required this.host,
    this.timeoutInSeconds = 15
  }):
  validation = Map<String, Map<String, dynamic>>();

  Server.clone(Server server) :
        this(
          host: server.host,
          timeoutInSeconds: server.timeoutInSeconds);

  void clone(Server server) {
    this.host = server.host;
    this.timeoutInSeconds = server.timeoutInSeconds;
  }

  Server.deserialization(Map<String, dynamic> json){
    this.host = Uri.parse(json['host']);
    this.timeoutInSeconds = json['timeoutInSeconds'] as int;
    this.validation = Map<String, Map<String, dynamic>>();
  }

  bool compare(Server server) {
    return (
        this.host == server.host &&
            this.timeoutInSeconds == server.timeoutInSeconds) ?
    true : false;
  }

  Map<String, dynamic> fillValidationUnit(String name) {
    Map<String, dynamic> structure = {
      'isValid': true,
      'errorMsg': null
    };
    return structure;
  }

  void initValidation() {
    validation = new Map();
    //init validation values on true
    validation['host'] = fillValidationUnit('host');
    validation['timeoutInSeconds'] = fillValidationUnit('timeoutInSeconds');
  }

  void setValidationError(String field, String errorMsg) {
    if (this.validation.containsKey(field) && this.validation[field] != null) {
      this.validation[field]!['isValid'] = false;
      this.validation[field]!['errorMsg'] = errorMsg;
    }
  }

  void setValidationCorrect(String field) {
    if (this.validation.containsKey(field) &&
        this.validation[field] != null &&
        !this.validation[field]!['isValid']) {
      this.validation[field]!['isValid'] = true;
      this.validation[field]!['errorMsg'] = null;
    }
  }

  factory Server.fromJson(Map<String, dynamic> json) => _$ServerFromJson(json);

  Map<String, dynamic> toJson() => _$ServerToJson(this);

  static int hasEncryptedEndpoint(String host) {
    if (host.toLowerCase().contains("https://")) return 1; //encrypted endpoint
    else if (host.toLowerCase().contains(
        "http://")) return 0; //not encrypted endpoint
    else
      return 2; //no http(s) beginning of string
  }

  String toString() {
    return this.host.toString();
  }
}

Server _$ServerFromJson(Map<String, dynamic> json) {
  return Server(
      host: Uri.parse(json['host']),
      timeoutInSeconds: json['timeoutInSeconds'] as int
  );
}

Map<String, dynamic> _$ServerToJson(Server instance) =>
    <String, dynamic>{
      'host': instance.host.toString(),
      'timeoutInSeconds': instance.timeoutInSeconds
    };


@JsonSerializable()
class Network {
  final _log = Logger('Storage.Network');
  late String name;
  late NetworkType networkType;
  late String chainID;

  //do not need to be stored - just to check if field is correct in settings section
  late Map<String, Map<String, dynamic>> validation;

  Network({required this.networkType, String? name, String? chainID}) {
    _log.info(
        "Network constructor: network type: $networkType, name: $name, chainID: $chainID");

    this.validation = Map<String, Map<String, dynamic>>();

    if (this.networkType == NetworkType.CUSTOM) {
      if (name == null || chainID == null) {
        _log.error("Invalid name or chain ID");
        throw Exception('Storage.Netork; invalid name or chainID');
      }
      //this.networkType is already defined
      this.name = name;
      this.chainID = chainID;
    }
    else {
      var network = NETWORK_CHAINS[this.networkType] ?? Map<String, dynamic>();

      /*if (network[NETWORK_CHAIN_NAME] == null ||
          network[NETWORK_CHAIN_NAME] == '' ||
          network[NETWORK_CHAIN_ID] == null ||
          network[NETWORK_CHAIN_ID] == '')
        _log.error("Predefined network name or chain is not valid: "
            "network: ${network[NETWORK_CHAIN_NAME]}"
            "chaindID: ${network[NETWORK_CHAIN_ID]}");*/

      this.name = network[NETWORK_CHAIN_NAME];
      this.chainID = network[NETWORK_CHAIN_ID];
    }
  }

  Map<String, dynamic> fillValidationUnit(String name) {
    Map<String, dynamic> structure = {
      'isValid': true,
      'errorMsg': null
    };
    return structure;
  }

  void initValidation() {
    validation = new Map();
    //init validation values on true
    validation['name'] = fillValidationUnit('name');
    validation['networkType'] = fillValidationUnit('networkType');
    validation['chainID'] = fillValidationUnit('chainID');
  }

  void setValidationError(String field, String errorMsg) {
    if (this.validation.containsKey(field) && this.validation[field] != null) {
      this.validation[field]!['isValid'] = false;
      this.validation[field]!['errorMsg'] = errorMsg;
    }
  }

  void setValidationCorrect(String field) {
    if (this.validation.containsKey(field) && this.validation[field] != null
        && !this.validation[field]!['isValid']) {
      this.validation[field]!['isValid'] = true;
      this.validation[field]!['errorMsg'] = null;
    }
  }

  bool compare(Network network) {
    return (this.name == network.name &&
                this.networkType == network.networkType &&
                this.chainID == network.chainID ) ?
    true : false;
  }


  Network.clone(Network network):
    this(networkType: network.networkType,
        name: network.name,
        chainID: network.chainID);


  void clone(Network network) {
    this.networkType = network.networkType;
    this.name = network.name;
    this.chainID = network.chainID;
  }


  factory Network.fromJson(Map<String, dynamic> json) => _$NetworkFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkToJson(this);
}

Network _$NetworkFromJson(Map<String, dynamic> json) =>
    Network(
    name: json['name'] as String,
    networkType: EnumUtil.fromStringEnum(NetworkType.values, json['networkType']),
    chainID: json['chainID'] as String,
  );

Map<String, dynamic> _$NetworkToJson(Network instance) => <String, dynamic>{
  'name': instance.name,
  'networkType': StringUtil.getWithoutTypeName(instance.networkType),
  'chainID': instance.chainID
};

class SelectedServer<T>{
  final _log = Logger('Storage.SelectedServer');
  late bool _isSelected;
  late T? _selected;

  SelectedServer({T? server}){
    _log.debug("Selected server: $server");
    _isSelected =  (server == null)? false: true;
    _selected = server;
  }

  SelectedServer.load({required bool isSelected, required T? server}){
    _log.debug("Load selected server; is selected: $isSelected, server: $server");
    _isSelected =  isSelected;
    _selected = server;
  }

  void set ({required T server})
  {
    _log.debug("Set selected server: $server");
    _isSelected = true;
    _selected = server;
  }

  void remove ()
  {
    _log.debug("Remove selected server");
    _isSelected = false;
  }

  bool isSetted(){
    _log.debug("Is selected server setted: $_isSelected");
    return _isSelected;
  }

  T getSelected(){
    if (_selected != null)
      return _selected!;
    else
      throw Exception("No server selected");
  }

  bool compare ({required T server}){
    if (isSetted()) {
      if (T == Server)
        return (server! as Server).compare((_selected as Server));
      else
        return false;
    }
    else
      return false;
  }

  /*SelectedServer.fromJson(Map<String, dynamic> json) {
    //var value = _$SelectedServerFromJson(json);
    //throw Exception ("");
    if (T is NodeServer)
       _$SelectedServerFromJson<NodeServer>(json);
    else
      throw Exception ("");
    //}
  }*/

  Map<String, dynamic> toJson() {
      if (this is SelectedServerNodeServer)
        return _$SelectedServerToJson<NodeServer>(this);
      else if (this is SelectedServerServerCloud)
        return _$SelectedServerToJson<ServerCloud>(this);
      else
        throw Exception ("SelectedServer.toJson; unknown generic format");
    }
}

class SelectedServerNodeServer extends SelectedServer<NodeServer>{

  SelectedServerNodeServer() : super();

  SelectedServerNodeServer.load ({required bool isSelected, required NodeServer? server}){
    SelectedServer<NodeServer>.load(isSelected: isSelected, server: server);

  }

  factory SelectedServerNodeServer.fromJson(Map<String, dynamic> json){
    return SelectedServerNodeServer.load(isSelected: json['isSelected'] as bool,
                        server: json['selected'] != null ? NodeServer.fromJson(json['selected']) as NodeServer : null);
  }

}

class SelectedServerServerCloud extends SelectedServer<ServerCloud>{

  SelectedServerServerCloud() : super();

  SelectedServerServerCloud.load ({required bool isSelected, required ServerCloud? server}){
    SelectedServer<ServerCloud>.load(isSelected: isSelected, server: server);
  }

  factory SelectedServerServerCloud.fromJson(Map<String, dynamic> json){
    return SelectedServerServerCloud.load(isSelected: json['isSelected'] as bool,
        server: json['selected'] != null ? ServerCloud.fromJson(json['selected']) as ServerCloud : null);
  }

}

class SelectedServerNetwork extends SelectedServer<Network>{

  SelectedServerNetwork() : super();

  SelectedServerNetwork.load ({required bool isSelected, required Network? server}){
    SelectedServer<Network>.load(isSelected: isSelected, server: server);
  }

  factory SelectedServerNetwork.fromJson(Map<String, dynamic> json){
    return SelectedServerNetwork.load(isSelected: json['isSelected'] as bool,
        server: json['selected'] != null ? Network.fromJson(json['selected']) as Network : null);
  }

}

/*R _$SelectedServerFromJson<R, T>(Map<String, dynamic> json) =>
    SelectedServer.load(
          isSelected: json['isSelected'] as bool,
          server: json['selected'] as T);*/

Map<String, dynamic> _$SelectedServerToJson<T>(SelectedServer instance) => <String, dynamic>{
    'isSelected': instance._isSelected,
    'selected': instance._selected
  };



@JsonSerializable()
class Networks{
  final _log = Logger('Storage.Networks');
  late List<Server> _servers;
  late SelectedServer  _selected;

  Networks(){
    _log.debug("Netowks.init");
    _servers = List<Server>.empty(growable: true);
  }


  Networks.load({required List<Server> servers,required SelectedServer selected}){
    _log.debug("Netowks.load; list of servers: $servers, selected server: $selected");
    _servers = servers;
    _selected = selected;
  }

  set servers(List<Server> value) {
    _servers = value;
  }

  SelectedServer get selected => _selected;

  set selected(SelectedServer value) {
    _selected = value;
  }

  bool isSelected() => _selected.isSetted();

  Server  getSelected() => _selected.getSelected();


  bool add(Server server){
    _log.info("Adding new server to storage; storage:$server");
    for (Server item in _servers){
      if (item.compare(server)){
        _log.warning("Server already exsists in database");
        return false;
      }
    }
    _servers.add(server);
    return true;
  }

  bool delete(Server server){
    _log.info("Delete server from storage; server:$server");
    for (Server item in _servers){
      if (item.compare(server)){
        _log.debug("Server found. Delete it from list.");
        _servers.remove(item);
        if(_selected.compare(server: server)){
          _log.debug("Server has been set as selected. Remove that mark.");
          _selected.remove();
        }
        return true;
      }
    }
    _log.info("Server not found in list. Nothing to remove");
    return false;
  }

  void setSelectedServer(Server server){
    _log.info("Set new selected server; server:$server");
    //check if this server exists in the list;otherwise add it
    for (Server item in _servers){
      if (item.compare(server)){
        _log.debug("Server found in list. Add server to selected server");
        this._selected.set(server: server);
        return;
      }
    }
    _log.info("Server not found in list. Add server to list and mark as selected");
    _servers.add(server);
    this._selected.set(server: server);
  }

  factory Networks.fromJson(Map<String, dynamic> json) => _$NetworksFromJson(json);

  Map<String, dynamic> toJson() => _$NetworksToJson(this);

  List<Server> get servers => _servers;
}

Networks _$NetworksFromJson(Map<String, dynamic> json) =>
    Networks.load(
        servers: json['servers'] != null
            ? (json['servers'] as List).map(
                (e) => Server.fromJson(e as Map<String, dynamic>)).toList()
            : List<Server>.empty(growable: true),
        selected:SelectedServerNetwork.fromJson(json['selected'])
    );

Map<String, dynamic> _$NetworksToJson(Networks instance) => <String, dynamic>{
  'servers': instance.servers != null ?
  instance.servers.map((item) => item.toJson()).toList() : null,
  'selected': instance.selected.toJson()
};

@JsonSerializable()
class NetworksCloud extends Networks {
  NetworksCloud() : super(){
    super.selected = SelectedServerServerCloud();
  }

  NetworksCloud.load({required List<ServerCloud> servers, required SelectedServerServerCloud selected}) : super() {
    super.servers = servers;
    super.selected = selected;
  }

  factory NetworksCloud.fromJson(Map<String, dynamic> json) => _$NetworksCloudFromJson(json);
  Map<String, dynamic> toJson() => _$NetworksCloudToJson(this);
}

NetworksCloud _$NetworksCloudFromJson(Map<String, dynamic> json) =>
  NetworksCloud.load(
      servers:
           (json['servers'] as List).map(
              (e) => ServerCloud.fromJson(e as Map<String, dynamic>)).toList(),
          //: List.empty(growable: true),
      selected: SelectedServerServerCloud.fromJson(json['selected'])
  );

Map<String, dynamic> _$NetworksCloudToJson(NetworksCloud instance) => <String, dynamic>{
  'servers': instance.servers != null ?
  instance.servers.map((item) => item.toJson()).toList() : null,
  'selected': instance.selected
};

@JsonSerializable()
class NetworksNode extends Networks {
  final _log = Logger("Networks:NetworksNode");

  NetworksNode(): super(){
    super.selected = SelectedServerNodeServer();
  }

  NetworksNode.load({required List<NodeServer> servers, required SelectedServerNodeServer selected}) {
    _log.debug("Init NetworksNode; servers: $servers, selected: $selected");
    super.servers = servers;
    super.selected = selected;
  }

  factory NetworksNode.fromJson(Map<String, dynamic> json) => _$NetworksNodeFromJson(json);
  Map<String, dynamic> toJson() => _$NetworksNodeToJson(this);
}

NetworksNode _$NetworksNodeFromJson(Map<String, dynamic> json) {
  Logger("Networks:NetworksNode").debug("NetworksNodeFromJson; json: $json");
  return NetworksNode.load(
      servers: //json['servers'] != null ?
          (json['servers'] as List).map(
              (e) => NodeServer.fromJson(e as Map<String, dynamic>)).toList(),
          //: List.empty(growable: true),
      selected: SelectedServerNodeServer.fromJson(json['selected'])
  );
}
Map<String, dynamic> _$NetworksNodeToJson(NetworksNode instance) => <String, dynamic>{
  'servers': instance.servers != null ?
  instance.servers.map((item) => item.toJson()).toList() : null,
  'selected': instance.selected
};

@JsonSerializable()
class NetworkNodeSet{
  final _log = Logger("NetworkNodeSet");

  late Map<NetworkType, NetworksNode> _nodes;
  late Map<NetworkType, Network> _networks ;

  NetworkNodeSet() : super(){
    _nodes = Map<NetworkType, NetworksNode>();
    _networks = Map<NetworkType, Network>();
    var t = 9;
  }

  NetworkNodeSet.load ({required Map<NetworkType, NetworksNode> nodes, required Map<NetworkType, Network> networks}){
    _nodes = nodes;
    _networks = networks;
  }

  Map<NetworkType, NetworksNode> get nodes => _nodes;

  set nodes(Map<NetworkType, NetworksNode> value) {
    _nodes = value;
  }

  bool networkTypeIsPredefined(NetworkType networkType){
    _log.debug("Is predefined network type: $networkType");
    return _networks[networkType] == null? false : true;
  }

  String networkTypeToString(NetworkType networkType){
    _log.debug("Get the name of network type: $networkType");
    if (_networks[networkType] == null)
      throw ("Network type '$networkType' is not in database.");

    if (_networks[networkType] != null) {
      _log.finest("The name of network type: ${_networks[networkType]!.name}");
      return _networks[networkType]!.name;
    }
    else
      throw Exception("NetworkNodeSet.networkTypeToString; Under network type: $networkType there is no record");
  }

  void add({required NetworkType networkType, required NodeServer server, bool isSelected = false }){
    _log.debug("add; networkType: $networkType, server: $server, is selected: $isSelected");
    _nodes[networkType] ??= NetworksNode();
    NetworksNode nodes = _nodes[networkType]!;
    nodes.add(server);
  }

  void deleteNetwork(NetworkType networkType){
    _log.debug("Delete network; networkType: $networkType");
    if (_nodes.containsKey(networkType) == false){
      _log.debug("No network type found in map of nodes.");
    }
    else {
      _nodes.remove(networkType);
    }
  }

  //add remove, update, etc

  factory NetworkNodeSet.fromJson(Map<String, dynamic> json) => _$NetworkNodeSetFromJson(json);
  Map<String, dynamic> toJson() => _$NetworkNodeSetToJson(this);

  static Map<NetworkType, NetworksNode> parseMapNodes(Map<String,dynamic> m){
    Logger("Parse map nodes").debug("map: $m");
    Map<NetworkType, NetworksNode> result ={};
    for(String key in m.keys){
    var u = m[key];
    //var u1 = jsonDecode(m[key]);
    result[EnumUtil.fromStringEnum(NetworkType.values, key)]=NetworksNode.fromJson(m[key]);
    }
    return result;
  }

  static Map<NetworkType, Network> parseMapNetworks(Map<String,dynamic> m){
    Logger("Parse map network").debug("map: $m");
    Map<NetworkType, Network> result ={};
    for(String key in m.keys){
      result[EnumUtil.fromStringEnum(NetworkType.values, key)]=Network.fromJson( m[key]);
    }
    return result;
  }

  static Map<String, dynamic> toStringMapNodes(Map<NetworkType, NetworksNode> m){
    Logger("ToStringMap nodes").debug("map: $m");
    Map<String, dynamic> result ={};
    m.forEach((key, value) {
      if (m[key] != null)
        result[StringUtil.getWithoutTypeName(key)]=m[key]!.toJson();
      else
        throw Exception("ToStringMap nodes; null value");
    });
    return result;
  }

  static Map<String, dynamic> toStringMapNewtorks(Map<NetworkType, Network> m){
    Logger("ToStringMapnetworks").debug("map: $m");
    Map<String, dynamic> result ={};
    m.forEach((key, value) {
      if (m[key] != null)
        result[StringUtil.getWithoutTypeName(key)]=m[key]!.toJson();
      else
        throw Exception("toStringMapNewtorks; null value");
    });
    return result;
  }

  Map<NetworkType, Network> get networks => _networks;

  set networks(Map<NetworkType, Network> value) {
    _networks = value;
  }
}


NetworkNodeSet _$NetworkNodeSetFromJson(Map<String, dynamic> json) =>
    NetworkNodeSet.load(nodes: NetworkNodeSet.parseMapNodes(json['nodes']),
    networks: NetworkNodeSet.parseMapNetworks(json['networks'])); //json['nodes']


Map<String, dynamic> _$NetworkNodeSetToJson(NetworkNodeSet instance) => <String, dynamic>{
  'nodes': NetworkNodeSet.toStringMapNodes(instance.nodes), //instance.nodes,
  'networks' : NetworkNodeSet.toStringMapNewtorks(instance.networks) //instance.networks
};


/////////////////////////////////
@JsonSerializable()
class NetworkCloudSet{
  final _log = Logger("NetworkCloudSet");

  //@JsonKey(fromJson: parseMap, toJson: toStringMap)
  late Map<NetworkTypeServer, NetworksCloud> _servers;

  NetworkCloudSet (){
    _servers = Map<NetworkTypeServer, NetworksCloud>();
  }

  NetworkCloudSet.load ({required Map<NetworkTypeServer, NetworksCloud> servers}){
    _servers = servers;
  }

  Map<NetworkTypeServer, NetworksCloud> get servers => _servers;

  set servers(Map<NetworkTypeServer, NetworksCloud> value) {
    _servers = value;
  }

  void add({required NetworkTypeServer networkTypeServer, required ServerCloud server, bool isSelected = false }){
    _log.debug("add; networkTypeServer: $networkTypeServer, server: $server, is selected: $isSelected");
    _servers[networkTypeServer] ??= NetworksCloud();
    NetworksCloud clouds = servers[networkTypeServer]!;
    clouds.add(server);
  }

  //add remove, update, etc

  factory NetworkCloudSet.fromJson(Map<String, dynamic> json) => _$NetworkCloudSetFromJson(json);
  Map<String, dynamic> toJson() => _$NetworkCloudSetToJson(this);

  static Map<NetworkTypeServer, NetworksCloud> parseMap(Map<String, dynamic> m){
    Logger("Parse map").debug("map: $m");
    Map<NetworkTypeServer, NetworksCloud> result ={};
    for(String key in m.keys){
      result[EnumUtil.fromStringEnum(NetworkTypeServer.values, key)]=NetworksCloud.fromJson( m[key]);
    }
    return result;
  }

  static Map<String, dynamic> toStringMap(Map<NetworkTypeServer, NetworksCloud> m){
    Logger("ToStringMap").debug("map: $m");
    Map<String, dynamic> result ={};
    m.forEach((key, value) {
      if (m[key] != null)
        result[StringUtil.getWithoutTypeName(key)]=m[key]!.toJson();
      else
        throw Exception("toStringMap; null value");
    });
    return result;
  }
}


NetworkCloudSet _$NetworkCloudSetFromJson(Map<String, dynamic> json) =>
    NetworkCloudSet.load(servers: NetworkCloudSet.parseMap(json['servers']));// NetworkNodeSet.parseMap(json['nodes'])


Map<String, dynamic> _$NetworkCloudSetToJson(NetworkCloudSet instance) => <String, dynamic>{
  'servers': NetworkCloudSet.toStringMap(instance.servers)
};


/*
 * Node server - connection to node
 */
@JsonSerializable()
class NodeServer extends Server {
  final _log = Logger("Server");

  NodeServer({
    required Uri host,
    int timeoutInSeconds = 15
  }) : super(host: host,
      timeoutInSeconds: timeoutInSeconds);

  NodeServer.deserialization(Map<String, dynamic> server) : super.deserialization(server){
    _log.debug("deserialization; server:$server");
  }

  NodeServer.clone({required NodeServer server}) : super.clone(server)
  {
    _log.debug("clone; server:$server");
  }

  bool compareInherited(NodeServer nodeServer) {
    return super.compare(nodeServer) ? true : false;
  }

  factory NodeServer.fromJson(Map<String, dynamic> json) => _$NodeServerFromJson(json);

  Map<String, dynamic> toJson() => _$NodeServerToJson(this);
}

NodeServer _$NodeServerFromJson(Map<String, dynamic> json) =>
    NodeServer.deserialization(
        json['server']);

Map<String, dynamic> _$NodeServerToJson(NodeServer instance) => {
    'server': _$ServerToJson(instance)
  };

/*
 * StorageServer
 */
@JsonSerializable()
class ServerCloud extends Server {
  final _log = Logger("ServerCloud");
  late String name;

  ServerCloud({ required this.name,
    required Uri host,
    int timeoutInSeconds = 15
  }) : super(host: host,
      timeoutInSeconds: timeoutInSeconds);

  ServerCloud.deserialization({required Map<String, dynamic> server, required String name}) : super.deserialization(server){
    _log.debug("deserialization; server: $server, name: $name");
    this.name = name;
  }

  ServerCloud.clone(ServerCloud server):super.clone(server) {
    _log.debug("clone; server: $server");
    this.name = server.name;
  }

  bool compareInherited(ServerCloud serverCloud) {
    return (super.compare(serverCloud) &&
            this.name == serverCloud.name) ?
        true : false;
  }

  void initValidation() {
    super.initValidation();
    //init validation values on true
    validation['name'] = fillValidationUnit('name');
  }

  factory ServerCloud.fromJson(Map<String, dynamic> json) =>
      _$ServerCloudFromJson(json);

  Map<String, dynamic> toJson() => _$ServerCloudToJson(this);
}

ServerCloud _$ServerCloudFromJson(Map<String, dynamic> json) =>
    ServerCloud.deserialization(
      server: json['server'],
      name: json['name'] as String);


Map<String, dynamic> _$ServerCloudToJson(ServerCloud instance) =>
  {
    'server': _$ServerToJson(instance),
    'name': instance.name
  };

class DBAkeyStorage {
  late SharedPreferences prefs;

  void init() async {
    //if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    //}
  }

  DBAKeys? getDBAKeys() {
    final data = prefs.getString("dbaKeys");
    if (data == null) {
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
      'mrtd_num': keys.mrtdNumber,
      'dob': keys.dateOfBirth.formatYYMMDD(),
      'doe': keys.dateOfExpiry.formatYYMMDD()
    });
    return prefs.setString("dbaKeys", data);
  }
}


int _NUM_OF_STEPS = 3;
//data stored in the singleton class
@JsonSerializable()
class StorageData {
  final _log = Logger('StorageData');
  late bool _isUpdatedInCurrentSession;
  late bool _loggingEnabled;
  late List<StepData> _steps;
  late NetworkNodeSet _nodeSet;
  late NetworkCloudSet _cloudSet;

  //should not be stored on disc
  late OutsideCallV0dot1 _outsideCall;
  late DBAkeyStorage dbAkeyStorage;


  StorageData() {
    this._isUpdatedInCurrentSession = false;
    this._loggingEnabled = false;
    this._nodeSet = NetworkNodeSet();
    this._cloudSet = NetworkCloudSet();

    this.dbAkeyStorage = DBAkeyStorage();
    this.dbAkeyStorage.init();

    this._steps = new List.from([
      StepDataEnterAccount(),//0
      StepDataScan(),//1
      StepDataAttestation()//2
    ]);

    this._outsideCall = OutsideCallV0dot1();
  }

  bool get isUpdatedInCurrentSession => _isUpdatedInCurrentSession;

  set isUpdatedInCurrentSession(bool value) {
    _isUpdatedInCurrentSession = value;
  }

  void fromStorageData(StorageData item) {
    this._loggingEnabled = item._loggingEnabled;
    this._nodeSet = item._nodeSet;
    this._cloudSet = item._cloudSet;
    this._steps = item._steps;

    //updated in current session
    this._isUpdatedInCurrentSession = item.isUpdatedInCurrentSession;
  }

  StorageData StorageDataDB(
      {required bool loggingEnabled, required List<StepData> steps, required NetworkNodeSet nodeSet, required NetworkCloudSet cloudSet}) {
    _log.debug("StorageDataDB:constructor;"
        "loggingEnabled: $loggingEnabled,"
        "steps: $steps,"
        "networkNodeSet: $nodeSet,"
        "networkCloudSet: $cloudSet");
    this._loggingEnabled = loggingEnabled;
    this._steps = steps;
    this._nodeSet = nodeSet;
    this._cloudSet = cloudSet ;

    //updated in current session
    this._isUpdatedInCurrentSession = true;
    return this;
  }

  bool get loggingEnabled => _loggingEnabled;

  set loggingEnabled(bool value) {
    _loggingEnabled = value;
  }

  OutsideCallV0dot1 get outsideCall => _outsideCall;

  set outsideCall(OutsideCallV0dot1 value) {
    _outsideCall = value;
  }

  List<StepData> getStorageDataAll() {
    return _steps;
  }

  StepData getStorageData(int index) {
    //out of array
    if (index > _NUM_OF_STEPS)
      throw Exception("StepData.getStorageData; index out of range");

    return _steps[index];
  }

  //add so storage list
  void addServerNode({required NodeServer item,required NetworkType networkType, bool isSelected = false}) {
    this._nodeSet.add(networkType: networkType, server: item, isSelected: isSelected );
  }

  //get list of nodes stored in storage;
  NetworksNode getServerNodes({required NetworkType networkType}) {
    _log.finer("Get nodes with type: $networkType");
    if (_nodeSet.nodes.containsKey(networkType) && _nodeSet.nodes[networkType] != null)
      return _nodeSet.nodes[networkType]!;
    else{
      _log.debug("No nodes with this type");
      throw Exception("StorageData.getServerNodes; No nodes with this type");
    }
  }

  NodeServer? getServerNodeSelected({required NetworkType networkType}) {
    _log.debug("Get selected node with type: $networkType");
    if (_nodeSet.nodes.containsKey(networkType) && _nodeSet.nodes[networkType] != null) {
      if (_nodeSet.nodes[networkType]!.selected.isSetted()){
        _log.debug("Selected node is found in database.");
        return _nodeSet.nodes[networkType]!.selected.getSelected();
      }
      else if (_nodeSet.nodes[networkType]!.servers.isNotEmpty){
        _log.debug("Selected node is not found in database. Return first one in the list.");
        return _nodeSet.nodes[networkType]!.servers.first as NodeServer;
      }
      else
        {
          _log.debug("No selected node and no elements in the database. "
              "Return null;");
          return null;
        }
    }
    else
    {
    _log.debug("No nodes with this type");
      return null;
    }
  }
/*
  NodeServer getDefaultNode() {
    return this.defaultNode;
  }*/

  NetworksCloud? getServerCloud({required NetworkTypeServer networkTypeServer}) {
    _log.finer("Get network servers with type: $networkTypeServer");
    if (_cloudSet.servers.containsKey(networkTypeServer))
      return _cloudSet.servers[networkTypeServer];
    else{
      _log.debug("No servers with this type");
      return null;
    }
  }

  ServerCloud? getServerCloudSelected({required NetworkTypeServer networkTypeServer}) {
    _log.debug("Get selected server with type: $networkTypeServer");
    if (_cloudSet.servers.containsKey(networkTypeServer)) {
      if (_cloudSet.servers[networkTypeServer]!.selected.isSetted()){
        _log.debug("Selected server is found in database.");
        return _cloudSet.servers[networkTypeServer]!.getSelected() as ServerCloud;
      }
      else if (_cloudSet.servers[networkTypeServer]!.servers.isNotEmpty){
        _log.debug("Selected server is not found in database. Return first one in the list.");
        return _cloudSet.servers[networkTypeServer]!.servers.first as ServerCloud;
      }
      else
      {
        _log.debug("No selected server and no elements in the database. "
            "Return null;");
        return null;
      }
    }
    else
    {
      _log.debug("No servers with this type");
      return null;
    }
  }
  DBAkeyStorage getDBAkeyStorage() {
    return this.dbAkeyStorage;
  }

  factory StorageData.fromJson(Map<String, dynamic> json) =>
      _$StorageDataFromJson(json);

  Map<String, dynamic> toJson() => _$StorageDataToJson(this);

  //save to local storage
  void save({Function (bool)? callback}) async {
    try {
      _log.info("Save");
      Map<String, dynamic> value = this.toJson();
      _log.debug("Save; data in map: $value");
      String forStorage = json.encode(value);
      _log.debug("Save; data in string: $forStorage");
      final storage = new FlutterSecureStorage();
      await storage.write(key: "data", value: forStorage);
      if (callback != null)
        callback(true);
    }
    catch (e) {
      _log.error("Save: exception; exc: ${e.toString()}");
      if (callback != null)
      callback(false);
    }
  }

  Future<void> load(
      {Function (bool isAlreadyUpdated, bool isValid, {String? exc})? callback}) async {
    try {
      Storage storage = Storage();
      if (storage.isUpdatedInCurrentSession) {
        if (callback != null)
          callback(true, false);
        return;
      }
      final storageDB = new FlutterSecureStorage();
      //await storageDB.readAll();//just to await when you run a script first time
      String? value = await storageDB.read(key: "data");
      if (value == null){
        _log.info("Nothing has been stored in the database yet.");
        if (callback != null)
          callback(true, false, exc: "Nothing has been stored in the database yet.");
        return;
      }

      storage.fromStorageData(StorageData.fromJson(jsonDecode(value)));
      if (callback != null)
        callback(false, true);
      return;
    }
    catch (e) {
      _log.error("Error when loading data from storage: ${e.toString()}");
      if (callback != null)
        callback(true, false, exc: e.toString());
      return;
    }
  }

  NetworkNodeSet get nodeSet => _nodeSet;
  set nodeSet(NetworkNodeSet value) {
    _nodeSet = value;
  }

  NetworkCloudSet get cloudSet => _cloudSet;
  set cloudSet(NetworkCloudSet value) {
    _cloudSet = value;
  }
}

StepDataListfromJson(Map<String, dynamic> list) {
  List<StepData> output = new List.empty(growable: true);
  output.add(StepDataEnterAccount.fromJson(list['StepDataEnterAccount']));
  output.add(StepDataScan.fromJson(list['StepDataScan']));
  output.add(StepDataAttestation.fromJson(list['StepDataAttestation']));
  return output;
}


Map<String, dynamic> StepDataListToJson(List<StepData> list) {
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
    steps: StepDataListfromJson(json['steps']),
    nodeSet: NetworkNodeSet.fromJson(json['nodeSet']),
    cloudSet: NetworkCloudSet.fromJson(json['cloudSet'])
  );
}

Map<String, dynamic> _$StorageDataToJson(StorageData instance) =>
    <String, dynamic>{
      'loggingEnabled': instance._loggingEnabled,
      'steps': StepDataListToJson(instance.getStorageDataAll()),
      'nodeSet' : instance._nodeSet.toJson(),
      'cloudSet' : instance._cloudSet.toJson(),
    };

//singleton class
class Storage extends StorageData {
  static Storage _singleton = Storage._internal();

  factory Storage(){
    //StorageData();
    return _singleton;
  }

  Storage._internal(){
    StorageData();
  }
}

class Storage1 {
  // make this nullable by adding '?'
  static Storage1? _instance;

  Storage1._() {
    // initialization and stuff
  }

  factory Storage1() {
    if (_instance == null) {
      _instance = new Storage1._();
    }
    // since you are sure you will return non-null value, add '!' operator
    return _instance!;
  }
}