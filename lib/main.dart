
import 'dart:io';

import 'package:eosio_passid_mobile_app/screen/requestType.dart';
import 'package:eosio_passid_mobile_app/settings/settings.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
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

Future<void> fillDatabase() async
{
  Storage storage = new Storage();
  storage.load();

  //to call it just one time
  if(storage.storageNodes().isNotEmpty)
    return;

  List<StorageNode> nodes = storage.storageNodes();
  StorageNode sn = new StorageNode(name: "EOS", host: "kylin.eosnode.io", port: 443, isEncryptedEndpoint: true, networkType: NetworkType.KYLIN, chainID: "abcedfdsaffdas");
  nodes.add(sn);
  storage.selectedNode = sn;
  storage.defaultNode = sn;

  sn = new StorageNode(name: "EOSIO testnet", host: "eosio.eosnode.io", port: 443, isEncryptedEndpoint: true, networkType: NetworkType.EOSIO_TESTNET, chainID: "fsadfsdafasdfasd");
  nodes.add(sn);

  sn = new StorageNode(name: "Jungle", host: "456786.eosnode.io", port: 443, isEncryptedEndpoint: true, networkType: NetworkType.CUSTOM, chainID: "abce5435345dsaffdas");
  nodes.add(sn);

  sn = new StorageNode(name: "ZeroPass Server", host: "mainenet.eosnode.io", port: 443, isEncryptedEndpoint: true, networkType: NetworkType.MAINNET, chainID: "abcedfdsdfgasfsdfasdfasdaffdas", notBlockchain: true);
  nodes.add(sn);

  StorageServer ss = new StorageServer(name: "mainServer", host: "163.172.144.187", port: 443, isEncryptedEndpoint: true);
  storage.storageServer = ss;

  StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0);
  storageStepEnterAccount.isUnlocked = true;

  StepDataAttestation stepDataAttestation = storage.getStorageData(2);
  stepDataAttestation.requestType = RequestType.ATTESTATION_REQUEST;
  stepDataAttestation.isOutsideCall = OutsideCall(reqeustedBy: "Ultra DEX");

  //storage.save();

  /*var t = HTTPrequest(url:"fdsf");
  t.getRequestJson((bool isValid, String msg ){
    var e = isValid;
    var w = msg;
    var r = 0;
  });*/
}

/*
* To load from disc previously stored values
*/
void loadDatabase({Function callbackStatus})
{
  Storage storage = new Storage();
  storage.load(callback: (isAlreadyUpdated, isValid, {String exc}){
    if (callbackStatus != null)
      callbackStatus(isAlreadyUpdated, isValid, exc:exc);
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
  @override
  void initState(){
    super.initState();
    initializeDateFormatting();

    //clean old logger handler
    LH.LoggerHandler loggerHandler = LH.LoggerHandler();
    loggerHandler.cleanLegacyLogs();

    //update database
    loadDatabase(callbackStatus: (isAlreadyUpdated, isValid, {String exc}){
      if (isValid)
        setState(() {});
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
  void randomTests(){
    return;
    Logger.root.onRecord.listen((record) {
      print('---------------${record.level.name}: ${record.time}: ${record.message}');
    });

    Keys keys = new Keys();
    keys.add(PrivateKey("5JrEwEFv9qmqrzLBnrQ4BmUzvTQedb5WX2vgb9KRdvq71D1GNUb"));
    StorageNode storageNode = StorageNode(name: "myNode", host: "https://api.kylin.alohaeos.com", port: 443, isEncryptedEndpoint: true, networkType: NetworkType.KYLIN, chainID: "5fff1dae8dc8e2fc4d5b23b2c7665c97f9e9d8edf2b6485a86ba311c25639191");
    Eosio eosio = Eosio(storageNode, EosioVersion.v1, keys);
    eosio.getNodeInfo().then((value) {
      print ("-------------------------------------");
      print (value);
    });
    
    eosio.getTableRows("eosio", "eosio", "producers").then((Map<String, dynamic> value){
      print(value);
      var y = 98;
    });


  }

@override
  Widget build(BuildContext context) {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print(
        '${record.loggerName} ${record.level.name}: ${record.time}: ${record.message}');
  });

    changeNavigationBarColor();

    randomTests();

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
