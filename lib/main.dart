import 'dart:async';

import 'package:dmrtd/extensions.dart';
import 'package:port_mobile_app/screen/flow/flowApp.dart';
import 'package:port_mobile_app/screen/nfc/authn/authn.dart';
import 'package:port_mobile_app/screen/qr/QRscreen.dart';
import 'package:port_mobile_app/screen/requestType.dart';
import 'package:port_mobile_app/constants/constants.dart';
import 'package:port_mobile_app/utils/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:port_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';

import 'package:port_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:port_mobile_app/screen/main/stepperIndex.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:port_mobile_app/screen/theme.dart';

import 'package:logging/logging.dart';
//import 'package:device_preview/device_preview.dart' as DevPreview;
//import 'package:port_mobile_app/utils/logging/loggerHandler.dart' as LH;
import 'package:port_mobile_app/connection/tools/eosio/eosio.dart';
import 'package:port_mobile_app/screen/qr/readQR.dart';
import 'package:port_mobile_app/screen/index/index.dart';
//import 'package:package_info_plus/package_info_plus.dart';

var RUN_IN_DEVICE_PREVIEW_MODE = false;
final _logStorage = Logger('Storage initialization');

void configureLogging() {
  Logger.root.level = Level.ALL; // Set to show all log levels
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      debugPrint('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      debugPrint('Stack trace:\n${record.stackTrace}');
    }
  });
}

void main() async{
  try {
      WidgetsFlutterBinding.ensureInitialized();
    
      // Configure logging first
      configureLogging();
      
      final rawSrvCrt = await rootBundle.load('assets/certs/port_server.cer');
      ServerSecurityContext.init(rawSrvCrt.buffer.asUint8List());

      //await Firebase.initializeApp(); obsolete

      runApp(Port());
    } catch (e, stack) {
    print('Fatal error during initialization: $e\n$stack');
    rethrow;
  }
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

      ServerCloud? serverCloud = storage.getServerCloudSelected(networkTypeServer: NetworkTypeServer.MAIN_SERVER);
    }

    ServerCloud? serverCloud = storage.getServerCloudSelected(networkTypeServer: NetworkTypeServer.MAIN_SERVER);

    StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0) as StepDataEnterAccount;
    storageStepEnterAccount.isUnlocked = true;

    StepDataAttestation stepDataAttestation = storage.getStorageData(2) as StepDataAttestation ;
    stepDataAttestation.requestType = RequestType.ATTESTATION_REQUEST;
  });

  //Keys keys= Keys();
  //keys.add(PrivateKey(TEST_PRIVATE_KEY));
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
    '/startFlow' : (context) => FlowApp(), //dynamic link skipped
    '/QR' : (context) => QRscreen()
    };



  void initialActions() async{
    //clean old logger handler
    Logger.root.level = Level.ALL;
    //LH.LoggerHandler loggerHandler = LH.LoggerHandler();
    //loggerHandler.cleanLegacyLogs();
    //update database
    loadDatabase(callbackStatus: (storage, isAlreadyUpdated, isValid, {String? exc}) async {
      if(isValid) {
        if(storage.loggingEnabled){
          //bool isStarted = await loggerHandler.startLoggingToAppMemory();
          //if(!isStarted) {
          //  print("main: couldn't start logging!");
          //  loggerHandler.stopLoggingToAppMemory((){}, (){});
          //}
        }
      }
    });
    fillDatabase().then((value) {});
  }


  @override
  Widget build(BuildContext context) {
    this.initialActions();

    //print metadata
    //getAppMetadata();

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