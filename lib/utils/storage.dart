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
  Uri host;
  int timeoutInSeconds;

  //do not need to be stored - just to check if field is correct in settings section
  Map<String, Map<String, dynamic>> validation;

  Server({
    @required this.host,
    this.timeoutInSeconds = 15
  });

  Server.clone(Server server) :
        this(
          host: server.host,
          timeoutInSeconds: server.timeoutInSeconds);

  void clone(Server server) {
    this.host = server.host;
    this.timeoutInSeconds = server.timeoutInSeconds;
  }

  Server.deserialization(Map<String, dynamic> json){
    this.host = json['host'] as Uri;
    this.timeoutInSeconds = json['timeoutInSeconds'] as int;
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
    if (this.validation.containsKey(field)) {
      this.validation[field]['isValid'] = false;
      this.validation[field]['errorMsg'] = errorMsg;
    }
  }

  void setValidationCorrect(String field) {
    if (this.validation.containsKey(field) &&
        !this.validation[field]['isValid']) {
      this.validation[field]['isValid'] = true;
      this.validation[field]['errorMsg'] = null;
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
      host: Uri.encodeFull(json['host']) as Uri,
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
  String name;
  NetworkType networkType;
  String chainID;

  //do not need to be stored - just to check if field is correct in settings section
  Map<String, Map<String, dynamic>> validation;

  Network({@required this.networkType, this.name = null, this.chainID = null}) {
    _log.info(
        "Network constructor: network type: $networkType, name: $name, chainID: $chainID");

    if (this.networkType == NetworkType.CUSTOM) {
      if (this.chainID == null || this.chainID == '') {
        _log.error("Invalid chain ID");
        throw Exception('Storage.Netork; invalid chainID');
      }

      if (this.name == null || this.name == '') {
        _log.error("Invalid network name");
        throw Exception('Storage.Netork; invalid network name');
      }
    }
    else {
      var network = NETWORK_CHAINS[this.networkType];
      if (network[NETWORK_CHAIN_NAME] == null ||
          network[NETWORK_CHAIN_NAME] == '' ||
          network[NETWORK_CHAIN_ID] == null || network[NETWORK_CHAIN_ID] == '')
        _log.error("Predefined network name or chain is not valid: "
            "network: ${network[NETWORK_CHAIN_NAME]}"
            "chaindID: ${network[NETWORK_CHAIN_ID]}");

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
    if (this.validation.containsKey(field)) {
      this.validation[field]['isValid'] = false;
      this.validation[field]['errorMsg'] = errorMsg;
    }
  }

  void setValidationCorrect(String field) {
    if (this.validation.containsKey(field) &&
        !this.validation[field]['isValid']) {
      this.validation[field]['isValid'] = true;
      this.validation[field]['errorMsg'] = null;
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

@JsonSerializable()
class Networks{
  final _log = Logger('Storage.Networks');
  List<Server> _servers;
  Server _selected = null;

  Networks(){
    _log.debug("Netowks.init");
    _servers = List<Server>();
  }


  Networks.load({List<Server> servers, Server selected}){
    _log.debug("Netowks.load; list of servers: $servers, selected server: $selected");
    _servers = servers;
    _selected = selected;
  }

  set servers(List<Server> value) {
    _servers = value;
  }

  Server get selected => _selected;

  set selected(Server value) {
    _selected = value;
  }

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
        if(_selected != null && _selected.compare(server)){
          _log.debug("Server has been set as selected. Remove that mark.");
          _selected = _servers.length > 0? _servers.first : null;
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
        this._selected = server;
        return;
      }
    }

    _log.info("Server not found in list. Add server to list and mark as selected");
    _servers.add(server);
    this._selected = server;
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
            : null,
        selected:Server.fromJson(json['selected'])
    );

Map<String, dynamic> _$NetworksToJson(Networks instance) => <String, dynamic>{
  'servers': instance.servers != null ?
  instance.servers.map((item) => item.toJson()).toList() : null,
  'selected': instance.selected
};

@JsonSerializable()
class NetworksCloud extends Networks {
  NetworksCloud() : super();

  NetworksCloud.load({List<ServerCloud> servers, ServerCloud selected}) : super() {
    super.servers = servers;
    super.selected = selected;
  }

  factory NetworksCloud.fromJson(Map<String, dynamic> json) => _$NetworksCloudFromJson(json);
  Map<String, dynamic> toJson() => _$NetworksCloudToJson(this);
}

NetworksCloud _$NetworksCloudFromJson(Map<String, dynamic> json) =>
  NetworksCloud.load(
      servers: json['servers'] != null
          ? (json['servers'] as List).map(
              (e) => ServerCloud.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      selected:json['selected'] != null? ServerCloud.fromJson(json['selected']) : null
  );

Map<String, dynamic> _$NetworksCloudToJson(NetworksCloud instance) => <String, dynamic>{
  'servers': instance.servers != null ?
  instance.servers.map((item) => item.toJson()).toList() : null,
  'selected': instance.selected
};

@JsonSerializable()
class NetworksNode extends Networks {
  final _log = Logger("Networks:NetworksNode");

  NetworksNode(): super();

  NetworksNode.load({List<NodeServer> servers, NodeServer selected}) {
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
      servers: json['servers'] != null
          ? (json['servers'] as List).map(
              (e) => NodeServer.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      selected: json['selected'] != null? NodeServer.fromJson(json['selected']) : null
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

  Map<NetworkType, NetworksNode> _nodes;
  Map<NetworkType, Network> _networks ;

  NetworkNodeSet() : super(){
    _nodes = Map<NetworkType, NetworksNode>();
    _networks = Map<NetworkType, Network>();
  }

  NetworkNodeSet.load ({Map<NetworkType, NetworksNode> nodes, Map<NetworkType, Network> networks}){
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

    _log.finest("The name of network type: ${_networks[networkType].name}");
    return _networks[networkType].name;
  }

  void add({NetworkType networkType, NodeServer server, bool isSelected = false }){
    _log.debug("add; networkType: $networkType, server: $server, is selected: $isSelected");
    _nodes[networkType] ??= NetworksNode();
    NetworksNode nodes = _nodes[networkType];
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
    if(m==null){
      Logger("Parse map").warning("Map is empty");
      return null;
    }
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
    if(m==null){
      Logger("Parse map").warning("Map is empty");
      return null;
    }
    Map<NetworkType, Network> result ={};
    for(String key in m.keys){
      result[EnumUtil.fromStringEnum(NetworkType.values, key)]=Network.fromJson( m[key]);
    }
    return result;
  }

  static Map<String, dynamic> toStringMapNodes(Map<NetworkType, NetworksNode> m){
    Logger("ToStringMap nodes").debug("map: $m");
    if(m==null) {
      Logger("ToStringMap").warning("Map is empty");
      return null;
    }
    Map<String, dynamic> result ={};
    m.forEach((key, value) {
      result[StringUtil.getWithoutTypeName(key)]=m[key].toJson();
    });
    return result;
  }

  static Map<String, dynamic> toStringMapNewtorks(Map<NetworkType, Network> m){
    Logger("ToStringMapnetworks").debug("map: $m");
    if(m==null) {
      Logger("ToStringMap").warning("Map is empty");
      return null;
    }
    Map<String, dynamic> result ={};
    m.forEach((key, value) {
      result[StringUtil.getWithoutTypeName(key)]=m[key].toJson();
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
  Map<NetworkTypeServer, NetworksCloud> _servers;

  NetworkCloudSet (){
    _servers = Map<NetworkTypeServer, NetworksCloud>();
  }

  NetworkCloudSet.load ({Map<NetworkTypeServer, NetworksCloud> servers}){
    _servers = servers;
  }

  Map<NetworkTypeServer, NetworksCloud> get servers => _servers;

  set servers(Map<NetworkTypeServer, NetworksCloud> value) {
    _servers = value;
  }

  void add({NetworkTypeServer networkTypeServer, ServerCloud server, bool isSelected = false }){
    _log.debug("add; networkTypeServer: $networkTypeServer, server: $server, is selected: $isSelected");
    _servers[networkTypeServer] ??= NetworksCloud();
    NetworksCloud clouds = servers[networkTypeServer];
    clouds.add(server);
  }

  //add remove, update, etc

  factory NetworkCloudSet.fromJson(Map<String, dynamic> json) => _$NetworkCloudSetFromJson(json);
  Map<String, dynamic> toJson() => _$NetworkCloudSetToJson(this);

  static Map<NetworkTypeServer, NetworksCloud> parseMap(Map<String, dynamic> m){
    Logger("Parse map").debug("map: $m");
    if(m==null){
      Logger("Parse map").warning("Map is empty");
      return null;
    }
    Map<NetworkTypeServer, NetworksCloud> result ={};
    for(String key in m.keys){
      result[EnumUtil.fromStringEnum(NetworkTypeServer.values, key)]=NetworksCloud.fromJson( m[key]);
    }
    return result;
  }

  static Map<String, dynamic> toStringMap(Map<NetworkTypeServer, NetworksCloud> m){
    Logger("ToStringMap").debug("map: $m");
    if(m==null) {
      Logger("ToStringMap").warning("Map is empty");
      return null;
    }
    Map<String, dynamic> result ={};
    m.forEach((key, value) {
      result[StringUtil.getWithoutTypeName(key)]=m[key].toJson();
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
    @required Uri host,
    int timeoutInSeconds = 15
  }) : super(host: host,
      timeoutInSeconds: timeoutInSeconds) {}

  NodeServer.deserialization(Map<String, dynamic> server) : super.deserialization(server){
    _log.debug("deserialization; server:$server");
    //this.network = network;
  }

  NodeServer.clone(NodeServer server) {
    _log.debug("clone; server:$server");
    super.clone(server);
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
  String name;

  ServerCloud({ @required this.name,
    @required Uri host,
    int timeoutInSeconds = 15
  }) : super(host: host,
      timeoutInSeconds: timeoutInSeconds);

  ServerCloud.deserialization(Map<String, dynamic> server, String name) : super.deserialization(server){
    _log.debug("deserialization; server: $server, name: $name");
    this.name = name;
  }

  ServerCloud.clone(ServerCloud server) {
    _log.debug("clone; server: $server");
    super.clone(server);
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
      json['server'],
      json['name'] as String);


Map<String, dynamic> _$ServerCloudToJson(ServerCloud instance) =>
  {
    'server': _$ServerToJson(instance),
    'name': instance.name
  };

class DBAkeyStorage {
  static SharedPreferences prefs;

  void init() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }
  }

  DBAKeys getDBAKeys() {
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
  bool _isUpdatedInCurrentSession;
  bool _loggingEnabled;
  List<StepData> _steps;
  NetworkNodeSet _nodeSet;
  NetworkCloudSet _cloudSet;

  //this should not be stored on disc
  DBAkeyStorage dbAkeyStorage;


  StorageData() {
    this._isUpdatedInCurrentSession = false;
    this._loggingEnabled = false;
    this._nodeSet = NetworkNodeSet();
    this._cloudSet = NetworkCloudSet();

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

  void fromStorageData(StorageData item) {
    this._loggingEnabled = item._loggingEnabled;
    this._nodeSet = item._nodeSet;
    this._cloudSet = item._cloudSet;
    this._steps = item._steps;

    //updated in current session
    this._isUpdatedInCurrentSession = item.isUpdatedInCurrentSession;
  }

  StorageData StorageDataDB(
      {bool loggingEnabled, List<StepData> steps, NetworkNodeSet nodeSet, NetworkCloudSet cloudSet}) {
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

  /*NodeServer getNode() {
    NodeServer defaultNode = this.getDefaultNode();
    NodeServer selectedNode = this.getSelectedNode();
    return selectedNode != null ? selectedNode : defaultNode;
  }*/


  List<StepData> getStorageDataAll() {
    return _steps;
  }

  StepData getStorageData(int index) {
    //out of array
    if (index > _NUM_OF_STEPS)
      return null;

    return _steps[index];
  }

  //add so storage list
  void addServerNode({NodeServer item, NetworkType networkType, bool isSelected = false}) {
    this._nodeSet.add(networkType: networkType, server: item, isSelected: isSelected );
  }

  //get list of nodes stored in storage;
  NetworksNode getServerNodes({@required NetworkType networkType}) {
    _log.finer("Get nodes with type: $networkType");
    if (_nodeSet.nodes.containsKey(networkType))
      return _nodeSet.nodes[networkType];
    else{
      _log.debug("No nodes with this type");
      return null;
    }
  }

  NodeServer getServerNodeSelected({@required NetworkType networkType}) {
    _log.debug("Get selected node with type: $networkType");
    if (_nodeSet.nodes.containsKey(networkType)) {
      if (_nodeSet.nodes[networkType].selected != null){
        _log.debug("Selected node is found in database.");
        return _nodeSet.nodes[networkType].selected;
      }
      else if (_nodeSet.nodes[networkType].servers.isNotEmpty){
        _log.debug("Selected node is not found in database. Return first one in the list.");
        return _nodeSet.nodes[networkType].servers.first;
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

  NetworksCloud getServerCloud({@required NetworkTypeServer networkTypeServer}) {
    _log.finer("Get network servers with type: $networkTypeServer");
    if (_cloudSet.servers.containsKey(networkTypeServer))
      return _cloudSet.servers[networkTypeServer];
    else{
      _log.debug("No servers with this type");
      return null;
    }
  }

  ServerCloud getServerCloudSelected({@required NetworkTypeServer networkTypeServer}) {
    _log.debug("Get selected server with type: $networkTypeServer");
    if (_cloudSet.servers.containsKey(networkTypeServer)) {
      if (_cloudSet.servers[networkTypeServer].selected != null){
        _log.debug("Selected server is found in database.");
        return _cloudSet.servers[networkTypeServer].selected;
      }
      else if (_cloudSet.servers[networkTypeServer].servers.isNotEmpty){
        _log.debug("Selected server is not found in database. Return first one in the list.");
        return _cloudSet.servers[networkTypeServer].servers.first;
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
  void save({Function callback(bool) = null}) async {
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

  void load(
      {Function (bool isAlreadyUpdated, bool isValid, {String exc}) callback}) async {
    try {
      Storage storage = Storage();
      if (storage.isUpdatedInCurrentSession) {
        if (callback != null)
          callback(true, false);
        return;
      }
      final storageDB = new FlutterSecureStorage();
      //await storageDB.readAll();//just to await when you run a script first time
      String value = await storageDB.read(key: "data");
      if (value == null){
        _log.info("Nothing has been stored in the database yet.");
        callback(true, false, exc: "Nothing has been stored in the database yet.");
        return;
      }

      var t = jsonDecode(value);
      storage.fromStorageData(StorageData.fromJson(jsonDecode(value)));
      if (callback != null)
        callback(false, true);
    }
    catch (e) {
      _log.error("Error when loading data from storage: ${e.toString()}");
      if (callback != null)
        callback(true, false, exc: e.toString());
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
  List<StepData> output = new List();
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

//singelton class
class Storage extends StorageData {
  static Storage _singleton = new Storage._internal();

  factory Storage(){
    StorageData();
    return _singleton;
  }

  Storage._internal(){}
}
