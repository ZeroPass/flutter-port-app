import 'dart:async';
import 'dart:convert';

import 'package:dmrtd/extensions.dart';
import 'package:eosio_port_mobile_app/connection/connectors/connectorChainEOS.dart';
import 'package:eosio_port_mobile_app/screen/nfc/authn/authn.dart';
import 'package:eosio_port_mobile_app/screen/qr/QRscreen.dart';
import 'package:eosio_port_mobile_app/screen/requestType.dart';
import 'package:eosio_port_mobile_app/constants/constants.dart';
import 'package:eosio_port_mobile_app/utils/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';

import 'package:eosio_port_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:eosio_port_mobile_app/screen/main/stepperIndex.dart';
import 'package:flutter/services.dart';
import 'package:flutter_document_reader_api/document_reader.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_port_mobile_app/screen/theme.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:logging/logging.dart';
//import 'package:device_preview/device_preview.dart' as DevPreview;
import 'package:eosio_port_mobile_app/utils/logging/loggerHandler.dart' as LH;
import 'package:eosio_port_mobile_app/connection/tools/eosio/eosio.dart';
import 'package:eosio_port_mobile_app/screen/qr/readQR.dart';
import 'package:eosio_port_mobile_app/screen/index/index.dart';
import 'package:package_info_plus/package_info_plus.dart';

//only for test
import 'package:idenfy_sdk_flutter/idenfy_sdk_flutter.dart';


var RUN_IN_DEVICE_PREVIEW_MODE = false;
final _logStorage = Logger('Storage initialization');
final _logMain = Logger('Main');


void getAppMetadata() async{
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String appName = packageInfo.appName;
  String packageName = packageInfo.packageName;
  String version = packageInfo.version;
  String buildNumber = packageInfo.buildNumber;
  String buildSignature = packageInfo.buildSignature;
  _logMain.debug("App name: $appName, "
      "package name: $packageName, "
      "build number: $buildNumber, "
      "version: $version, "
      "build signature: $buildSignature");
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final rawSrvCrt = await rootBundle.load('assets/certs/port_server.cer');
  ServerSecurityContext.init(rawSrvCrt.buffer.asUint8List());

  await Firebase.initializeApp();

  runApp(Port());
}

Map<NetworkType, Network> fillNetworkTypes(Map<NetworkType, Network> networks){
  _logStorage.fine("Fill network type if it's empty.");
  if (networks != null && networks.isNotEmpty) {
    _logStorage.fine("Main.fillNetworkTypes;Netowrk types is already written in database.");
  }

  NetworkType.values.forEach((element) {
    if (NETWORK_CHAINS[element] != null && NETWORK_CHAINS[element]![NETWORK_CHAIN_NAME] != null
        && NETWORK_CHAINS[element]![NETWORK_CHAIN_ID] != null) {
      _logStorage.finer("Network type: $element, "
          "name: ${NETWORK_CHAINS[element]![NETWORK_CHAIN_NAME]}"
          "chainID: ${NETWORK_CHAINS[element]![NETWORK_CHAIN_ID]}");
      if ( NETWORK_CHAINS[element]![NETWORK_CHAIN_DEFAULT] == true)
      networks[element] = Network(networkType: element,
          name: NETWORK_CHAINS[element]![NETWORK_CHAIN_NAME] as String,
          chainID: NETWORK_CHAINS[element]![NETWORK_CHAIN_ID] as String);
      else
        networks[element] = Network(networkType: element,
            name: "Custom",
            chainID: "Write you own chainID.");
    }
  });
  return networks;
}


Future<void> fillDatabase() async
{
  Storage storage = new Storage();

  Map<NetworkType, Network> nets = fillNetworkTypes(storage.nodeSet.networks);
  if (nets != null)
    storage.nodeSet.networks = nets;
  await storage.load(callback: (bool isAlreadyUpdated, bool isValid, {String? exc}) {
    if (storage.nodeSet.nodes.isEmpty) {
      storage.nodeSet.add(networkType: NetworkType.KYLIN,
          isSelected: true,
          server: NodeServer(host: Uri.parse("https://kylin.eosnode.io:443")));

      storage.nodeSet.add(networkType: NetworkType.EOSIO_TESTNET,
          isSelected: false,
          server: NodeServer(host: Uri.parse("https://eosio.eosnode.io:443")));

      storage.nodeSet.add(networkType: NetworkType.EOSIO_TESTNET,
          isSelected: false,
          server: NodeServer(host: Uri.parse("https://456786.eosnode.io:443")));

      storage.nodeSet.add(networkType: NetworkType.MAINNET,
          isSelected: false,
          server: NodeServer(host: Uri.parse("https://mainenet.eosnode.io:443")));

      storage.nodeSet.add(networkType: NetworkType.CUSTOM,
          isSelected: false,
          server: NodeServer(host: Uri.parse("https://custom.eosnode.io:443")));
    }

    if (storage.cloudSet.servers.isEmpty){
      storage.cloudSet.add(networkTypeServer: NetworkTypeServer.MAIN_SERVER,
          isSelected: true,
          server: ServerCloud(name: "ZeroPass server", host: Uri.parse("https://portdevq8mjmnrw-portdev1.functions.fnc.fr-par.scw.cloud")));

      storage.cloudSet.servers[NetworkTypeServer.MAIN_SERVER]!.selected.set(server:
      ServerCloud(name: "ZeroPass server", host: Uri.parse("https://portdevq8mjmnrw-portdev1.functions.fnc.fr-par.scw.cloud")));

    }

    ServerCloud? serverCloud = storage.getServerCloudSelected(networkTypeServer: NetworkTypeServer.MAIN_SERVER);

    StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0) as StepDataEnterAccount;
    storageStepEnterAccount.isUnlocked = true;

    StepDataAttestation stepDataAttestation = storage.getStorageData(2) as StepDataAttestation ;
    stepDataAttestation.requestType = RequestType.ATTESTATION_REQUEST;
  });


  
  Keys keys= Keys();
  keys.add(PrivateKey(TEST_PRIVATE_KEY));

  //Eosio eosio=Eosio(storageNode: NodeServer(host: Uri.parse("https://jungle3.greymass.com")), version: EosioVersion.v2, privateKeys: keys);
  ConnectorChainEOS connectorChainEOS = ConnectorChainEOS(url: Uri.parse("https://jungle3.greymass.com1"), keys:keys);
connectorChainEOS.getData(dscBinary: "");


  storage.save();

  storage.load();

}

/*
* To load from disc previously stored values
*/
void loadDatabase({required Future<void> Function(Storage, bool, bool, {String? exc}) callbackStatus})
{
  Storage storage = new Storage();
  storage.load(callback: (isAlreadyUpdated, isValid, {String? exc}){
    callbackStatus.call(storage, isAlreadyUpdated, isValid, exc:exc);
  });
}

class Port extends StatelessWidget {

  dynamic routes = {
    '/index' : (context) => IndexScreen(),
    '/home' : (context) => PortStepperScreen(), //looking for dynamic links
    '/homeMagnetLink' : (context) => PortStepperWidget(), //dynamic link skipped
    '/QR' : (context) => QRscreen()
    };



  void initialActions() async{
    //clean old logger handler
    Logger.root.level = Level.ALL;
    LH.LoggerHandler loggerHandler = LH.LoggerHandler();
    loggerHandler.cleanLegacyLogs();
    //update database
    loadDatabase(callbackStatus: (storage, isAlreadyUpdated, isValid, {String? exc}) async {
      if(isValid) {
        if(storage.loggingEnabled){
          bool isStarted = await loggerHandler.startLoggingToAppMemory();
          if(!isStarted) {
            print("main: couldn't start logging!");
            loggerHandler.stopLoggingToAppMemory((){}, (){});
          }
        }
      }
    });
    fillDatabase().then((value) {});
  }

  void test(BuildContext context) async{
    List certificates = [];
    final manifestJson =  await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final certPaths = json.decode(manifestJson).keys.where((String key) => key.startsWith('assets/certificates'));

    for (var path in certPaths) {
      var findExt = path.split('.');
      var pkdResourceType = 0;
      if (findExt.length > 0)
        pkdResourceType = PKDResourceType.getType(findExt[findExt.length - 1].toLowerCase());
      ByteData byteData = await rootBundle.load(path);
      var certBase64 = base64.encode(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      certificates.add({"binaryData": certBase64, "resourceType": pkdResourceType});
    }

    DocumentReader.addPKDCertificates(certificates).then((value) => print("certificates added"));

    ////////////////////////////////////temp end
  }

  @override
  Widget build(BuildContext context) {
    this.initialActions();

    this.test(context);





    //print metadata
    getAppMetadata();

    return PlatformProvider(
      //initialPlatform: initialPlatform,
        builder: (BuildContext context) => PlatformApp(
            title: 'Port',
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate
            ],
            material: (_, __) => MaterialAppData(
                theme: AndroidTheme().getLight(),
                darkTheme: AndroidTheme().getDark(),
                routes: routes),
            cupertino: (_, __) => CupertinoAppData(
                theme: iosThemeData(),
                routes: routes),
            home: Index()
    ));

  }
}