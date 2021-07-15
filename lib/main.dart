
import 'dart:async';
import 'dart:io';

import 'package:eosdart/eosdart.dart';
import 'package:eosio_port_mobile_app/screen/requestType.dart';
import 'package:eosio_port_mobile_app/constants/constants.dart';
import 'package:eosio_port_mobile_app/utils/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepper.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepScan/stepScanHeader/stepScanHeader.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepAttestation/stepAttestationHeader/stepAttestationHeader.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepReview/stepReview.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepReview/stepReviewHeader/stepReviewHeader.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_port_mobile_app/screen/theme.dart';
import 'package:eosio_port_mobile_app/screen/settings/settings.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logging/logging.dart';
import 'package:eosio_port_mobile_app/screen/slideToSideRoute.dart';
//import 'package:device_preview/device_preview.dart' as DevPreview;
import 'package:eosio_port_mobile_app/utils/logging/loggerHandler.dart' as LH;
import 'package:eosio_port_mobile_app/connection/tools/eosio/eosio.dart';
import 'package:eosio_port_mobile_app/screen/qr/readQR.dart';
import 'package:eosio_port_mobile_app/screen/main/warningBar.dart';

import 'package:eosio_port_mobile_app/connection/connectors/connectorChainEOS.dart';
import 'package:eosio_port_mobile_app/screen/qr/structure.dart';

var RUN_IN_DEVICE_PREVIEW_MODE = false;
final _logStorage = Logger('Storage initialization');

GlobalKey<ScaffoldState> _SCAFFOLD_KEY = GlobalKey<ScaffoldState>();

void main() {
  runApp(
      /*RUN_IN_DEVICE_PREVIEW_MODE?
        DevPreview.DevicePreview(
          enabled: !kReleaseMode,
          builder: (context) => PassId(),
        ):*/
        PassId()
  );
  //changeNavigationBarColor();
}

Map<NetworkType, Network> fillNetworkTypes(Map<NetworkType, Network> networks){
  _logStorage.fine("Fill network type if it's empty.");
  if (networks != null && networks.isNotEmpty) {
    _logStorage.fine("Main.fillNetworkTypes;Netowrk types is already written in database.");
    //throw Exception("Main.fillNetworkTypes;Netowrk types is already written in database.");
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
  Completer<bool> send = new Completer<bool>();
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
          server: ServerCloud(name: "ZeroPass server", host: Uri.parse("https://163.172.144.187")));

      storage.cloudSet.servers[NetworkTypeServer.MAIN_SERVER]!.selected.set(server:
      ServerCloud(name: "ZeroPass server", host: Uri.parse("https://163.172.144.187")));

      ServerCloud? serverCloud = storage.getServerCloudSelected(networkTypeServer: NetworkTypeServer.MAIN_SERVER);
    }

    ServerCloud? serverCloud = storage.getServerCloudSelected(networkTypeServer: NetworkTypeServer.MAIN_SERVER);

    StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0) as StepDataEnterAccount;
    storageStepEnterAccount.isUnlocked = true;

    StepDataAttestation stepDataAttestation = storage.getStorageData(2) as StepDataAttestation ;
    stepDataAttestation.requestType = RequestType.ATTESTATION_REQUEST;
    //storage.outsideCall = OutsideCallV0dot1();
    //storage.outsideCall.setV0dot1(qRserverStructure:
    //                        QRserverStructure(accountID: "testacc",
    //                                          requestType: RequestType.FAKE_PERSONAL_INFORMATION_REQUEST,
    //                                          host: Server(host: Uri.parse("https://test-server.io"))));


  });


  Keys keys= Keys();
  keys.add(PrivateKey(TEST_PRIVATE_KEY));
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

class PassId extends StatelessWidget {

  dynamic routes = {
    '/home' : (context) => PassIdWidget(),
    '/QR' : (context) => ReadQR()
    };

  @override
  Widget build(BuildContext context) {
    Storage storage = Storage();
    StepDataAttestation stepDataAttestation = storage.getStorageData(2) as StepDataAttestation;
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
            home: PassIdWidget()
    ));

  }
}

///*****************************************************************************
///
/// PassIdWidget
///
///****************************************************************************/

class PassIdWidget extends StatefulWidget {
  @override
  _PassIdWidgetState createState() => _PassIdWidgetState();
}

class _PassIdWidgetState extends State<PassIdWidget> with TickerProviderStateMixin {
  final _log = Logger("main");

  @override
  void initState(){
    super.initState();
    initializeDateFormatting();

    randomTests();

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
        setState(() {});
      }
    });

    fillDatabase().then((value) {
        setState(() {});
      });

    if(!Platform.isIOS){
      SystemChrome.setEnabledSystemUIOverlays([]); // hide status bar
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  void randomTests() async{
    return;
    /*Keys keys = new Keys();
    keys.add(PrivateKey("5KVTRoGQ1kW5BxzQ6SavdppVQPwVzfQGSBdCANc5gJpX74tPyXo"));
    StorageNode storageNode = StorageNode(name: "myNode", host: "https://api-kylin.eoslaomao.com", port: 443, isEncryptedEndpoint: true, networkType: NetworkType.KYLIN, chainID: "5fff1dae8dc8e2fc4d5b23b2c7665c97f9e9d8edf2b6485a86ba311c25639191");
    Eosio eosio = Eosio(storageNode, EosioVersion.v1, keys, httpTimeout: 60);

    eosio.getAccountInfo("frkavbajti12").then((value) {
      print (value);
      });

    Map data = {
      'from': 'frkavbajti12',
      'to': 'frkavbajti13',
      'quantity': '0.0001 EOS',
      'memo': 'ejga test',
    };

    eosio.pushTransaction("eosio.token", "transfer", [Eosio.createAuth("frkavbajti12", "active")], data).then((PushTrxResponse value) {
      if (value.isValid)
        var t = 9;
      else
        print(value.error);
    });*/
  }

@override
  Widget build(BuildContext context) {
  _SCAFFOLD_KEY = GlobalKey<ScaffoldState>();
    changeNavigationBarColor();

    Storage storage = Storage();
    StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0) as StepDataEnterAccount;
    StepDataAttestation stepDataAttestation = storage.getStorageData(2) as StepDataAttestation;

    return PlatformScaffold(
        key: _SCAFFOLD_KEY,
        appBar: PlatformAppBar(
          automaticallyImplyLeading: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  width: 35,
                  height: 35,
                  child: Image(image: AssetImage('assets/images/passid.png'))),
              Text("     Port",
                style: TextStyle(color: Colors.white)), 
              Text("ID", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
            ],
          ),
          trailingActions: <Widget>[
            PlatformIconButton(
              cupertino: (_,__) => CupertinoIconButtonData(
                icon: Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 35
                ), 
                padding: EdgeInsets.all(0),
              ),
              materialIcon: Icon(Icons.menu, size: 30.0),
              material: (_,__) => MaterialIconButtonData(tooltip: 'Settings'),
              onPressed: () {
                final page = Settings();
                Navigator.of(context).push(SlideToSideRoute(page));
              }
            )
          ],
        ),
        body: MultiBlocProvider(
          providers: [
            BlocProvider<StepEnterAccountHeaderBloc>(
                create: (BuildContext context) => StepEnterAccountHeaderBloc(networkType: storageStepEnterAccount.networkType)),
            BlocProvider<StepScanHeaderBloc>(
                create: (BuildContext context) => StepScanHeaderBloc()),
            BlocProvider<StepEnterAccountBloc>(
                create: (BuildContext context) => StepEnterAccountBloc(networkType: storageStepEnterAccount.networkType)),
            BlocProvider<StepScanBloc>(
                create: (BuildContext context) => StepScanBloc()),
            BlocProvider<StepAttestationBloc>(
                create: (BuildContext context) => StepAttestationBloc(requestType: stepDataAttestation.requestType)),
            BlocProvider<StepAttestationHeaderBloc>(
                create: (BuildContext context) => StepAttestationHeaderBloc(requestType: stepDataAttestation.requestType)),
            BlocProvider<StepReviewBloc>(
                create: (BuildContext context) => StepReviewBloc()),
            BlocProvider<StepReviewHeaderBloc>(
                create: (BuildContext context) => StepReviewHeaderBloc()),
            BlocProvider<StepperBloc>(
                create: (BuildContext context) => StepperBloc(maxSteps: 4 /*set maximum steps you have in any/all modes*/)),
          ],
          child: KeyboardDismisser(
            gestures:[
              GestureType.onTapDown,
              GestureType.onTapUp,
              GestureType.onTap,
              GestureType.onTapCancel,
              GestureType.onSecondaryTapDown,
              GestureType.onSecondaryTapUp,
              GestureType.onSecondaryTapCancel,
              GestureType.onDoubleTap,
              GestureType.onLongPress,
              GestureType.onLongPressStart,
              GestureType.onLongPressMoveUpdate,
              GestureType.onLongPressUp,
              GestureType.onLongPressEnd,
              GestureType.onVerticalDragDown,
              GestureType.onVerticalDragStart,
              GestureType.onVerticalDragUpdate,
              GestureType.onVerticalDragEnd,
              GestureType.onVerticalDragCancel,
              GestureType.onHorizontalDragDown,
              GestureType.onHorizontalDragStart,
              GestureType.onHorizontalDragUpdate,
              GestureType.onHorizontalDragEnd,
              GestureType.onHorizontalDragCancel,
              GestureType.onForcePressStart,
              GestureType.onForcePressPeak,
              GestureType.onForcePressUpdate,
              GestureType.onForcePressEnd,
              GestureType.onPanDown,
              GestureType.onPanUpdateDownDirection,
              GestureType.onPanUpdateUpDirection,
              GestureType.onPanUpdateLeftDirection,
              GestureType.onPanUpdateRightDirection,
            ],
            child:Scaffold(
              //resizeToAvoidBottomInset: false,
            body:Column(

                children: <Widget>[
                  WarningBar(outsideCall: storage.outsideCall),
                  new Expanded(child: StepperForm())
                ])
            )
        ))
    );
  }
}
