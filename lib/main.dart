
import 'dart:io';

import 'package:eosdart/eosdart.dart';
import 'package:eosio_passid_mobile_app/screen/requestType.dart';
import 'package:eosio_passid_mobile_app/constants/constants.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/utils/structure.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScanHeader/stepScanHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestationHeader/stepAttestationHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepReview/stepReview.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepReview/stepReviewHeader/stepReviewHeader.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import 'package:eosio_passid_mobile_app/screen/settings/settings.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logging/logging.dart';
import 'package:eosio_passid_mobile_app/screen/slideToSideRoute.dart';
import 'package:device_preview/device_preview.dart' as DevPreview;
import 'package:eosio_passid_mobile_app/utils/logging/loggerHandler.dart' as LH;

import 'package:eosio_passid_mobile_app/utils/net/eosio/eosio.dart';

var RUN_IN_DEVICE_PREVIEW_MODE = false;
final _logStorage = Logger('Storage initialization');

void main() {
  //SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //  systemNavigationBarColor: Colors.grey,
  //));

  runApp(
      RUN_IN_DEVICE_PREVIEW_MODE?
        DevPreview.DevicePreview(
          enabled: !kReleaseMode,
          builder: (context) => PassId(),
        ):
        PassId()
  );
  //changeNavigationBarColor();
}

Map<NetworkType, Network> fillNetworkTypes(Map<NetworkType, Network> networks){
  _logStorage.fine("Fill network type if it's empty.");
  if (networks != null && networks.isNotEmpty) {
    _logStorage.fine("Netowrk types is already written in database.");
    return null;
  }

  NetworkType.values.forEach((element) {
    if (NETWORK_CHAINS[element] != null && NETWORK_CHAINS[element][NETWORK_CHAIN_DEFAULT] == true) {
      _logStorage.finer("Network type: $element, "
          "name: ${NETWORK_CHAINS[element][NETWORK_CHAIN_NAME]}"
          "chainID: ${NETWORK_CHAINS[element][NETWORK_CHAIN_ID]}");

      networks[element] = Network(networkType: element,
          name: NETWORK_CHAINS[element][NETWORK_CHAIN_NAME],
          chainID: NETWORK_CHAINS[element][NETWORK_CHAIN_ID]);
    }
  });
  return networks;
}


Future<void> fillDatabase() async
{
  Storage storage = new Storage();
  storage.load(callback: (isAlreadyUpdated, isValid, {exc}) {
    var test = 8;
  });

  //to call it just one time
  //if(storage.nodeSet)
  //  return;

  var t = storage.nodeSet;
  Map<NetworkType, Network> nets = fillNetworkTypes(storage.nodeSet.networks);
  if (nets != null)
    storage.nodeSet.networks = nets;

  if (storage.nodeSet.nodes.isEmpty) {
    storage.nodeSet.add(networkType: NetworkType.KYLIN,
        isSelected: true,
        server: NodeServer(host: "kylin.eosnode.io",
            port: 443,
            isEncryptedEndpoint: true));

    storage.nodeSet.add(networkType: NetworkType.EOSIO_TESTNET,
        isSelected: false,
        server: NodeServer(host: "eosio.eosnode.io",
            port: 443,
            isEncryptedEndpoint: true));

    storage.nodeSet.add(networkType: NetworkType.EOSIO_TESTNET,
        isSelected: false,
        server: NodeServer(host: "456786.eosnode.io",
            port: 443,
            isEncryptedEndpoint: true));

    storage.nodeSet.add(networkType: NetworkType.MAINNET,
        isSelected: false,
        server: NodeServer(host: "mainenet.eosnode.io",
            port: 443,
            isEncryptedEndpoint: true));
  }

  if (storage.cloudSet.servers.isEmpty){
    storage.cloudSet.add(networkTypeServer: NetworkTypeServer.MAIN_SERVER,
    isSelected: true,
    server: ServerCloud(name: "ZeroPass server", host: "163.172.144.187", port: 443, isEncryptedEndpoint: true));
  }

  StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0);
  storageStepEnterAccount.isUnlocked = true;

  StepDataAttestation stepDataAttestation = storage.getStorageData(2);
  stepDataAttestation.requestType = RequestType.ATTESTATION_REQUEST;
  stepDataAttestation.isOutsideCall = OutsideCall(reqeustedBy: "Ultra DEX");
}

/*
* To load from disc previously stored values
*/
void loadDatabase({Future<void> Function(Storage, bool, bool, {String exc}) callbackStatus})
{
  Storage storage = new Storage();
  storage.load(callback: (isAlreadyUpdated, isValid, {String exc}){
    callbackStatus?.call(storage, isAlreadyUpdated, isValid, exc:exc);
  });
}

class PassId extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return PlatformProvider(
      //initialPlatform: initialPlatform,
        builder: (BuildContext context) => PlatformApp(
            title: 'PassID',
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate
            ],
            android: (_) => MaterialAppData(
                theme: AndroidTheme().getLight(),
                darkTheme: AndroidTheme().getDark()),
            ios: (_) => CupertinoAppData(
              theme: iosThemeData(),

            ),
            home: PassIdWidget()));

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
    loadDatabase(callbackStatus: (storage, isAlreadyUpdated, isValid, {String exc}) async {
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
    //WidgetsBinding.instance
    //    .addPostFrameCallback((_) => widget.scaffoldContext.state.showSnackBar(SnackBar(content: Text("Your message here..")));
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
  // Logger.root.level = Level.ALL;
  // Logger.root.onRecord.listen((record) {
  //   print(
  //       '${record.loggerName} ${record.level.name}: ${record.time}: ${record.message}');
  // });

    changeNavigationBarColor();



    return PlatformScaffold(
        appBar: PlatformAppBar(
          automaticallyImplyLeading: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  width: 35,
                  height: 35,
                  child: Image(image: AssetImage('assets/images/passid.png'))),
              Text("     Pass",
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
              androidIcon: Icon(Icons.menu, size: 30.0),
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
                create: (BuildContext context) => StepEnterAccountHeaderBloc()),
            BlocProvider<StepScanHeaderBloc>(
                create: (BuildContext context) => StepScanHeaderBloc()),
            BlocProvider<StepEnterAccountBloc>(
                create: (BuildContext context) => StepEnterAccountBloc()),
            BlocProvider<StepScanBloc>(
                create: (BuildContext context) => StepScanBloc()),
            BlocProvider<StepAttestationBloc>(
                create: (BuildContext context) => StepAttestationBloc()),
            BlocProvider<StepAttestationHeaderBloc>(
                create: (BuildContext context) => StepAttestationHeaderBloc()),
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
              GestureType. onLongPress,
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
            body:StepperForm()),
        ))
    );
  }
}
