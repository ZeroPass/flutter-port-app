import 'package:eosio_passid_mobile_app/settings/settings.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScanHeader/stepScanHeader.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import 'package:eosio_passid_mobile_app/screen/settings/settings.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logging/logging.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/provider/asset_flare.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print(
        '${record.loggerName} ${record.level.name}: ${record.time}: ${record.message}');
  });
  runApp(PassId());
}

void fillDatabase()
{
  print("fill database");
  Storage storage = new Storage();

  //to call it just one time
  if(storage.storageNodes().isNotEmpty)
    return;

  print("---------------------------------------------------in fill datatbase");
  List<StorageNode> nodes = storage.storageNodes();
  StorageNode sn = new StorageNode(name: "EOS", host: "kylin.eosnode.io", port: 443, isEncryptedEndpoint: true, networkType: NetworkType.KYLIN, chainID: "abcedfdsaffdas");
  nodes.add(sn);
  storage.selectedNode = sn;
  storage.defaultNode = sn;

  sn = new StorageNode(name: "EOSIO testnet", host: "eosio.eosnode.io", port: 443, isEncryptedEndpoint: true, networkType: NetworkType.EOSIO_TESTNET, chainID: "fsadfsdafasdfasd");
  nodes.add(sn);

  sn = new StorageNode(name: "Jungle", host: "456786.eosnode.io", port: 443, isEncryptedEndpoint: true, networkType: NetworkType.CUSTOM, chainID: "abce5435345dsaffdas");
  nodes.add(sn);

  sn = new StorageNode(name: "ZeroPass Server", host: "mainenet.eosnode.io", port: 443, isEncryptedEndpoint: true, networkType: NetworkType.MAINNET, chainID: "abcedfdsdfgasfsdfasdfasdaffdas");
  nodes.add(sn);

  StorageServer ss = new StorageServer(name: "mainServer", host: "51.15.224.168", port: 443, isEncryptedEndpoint: true);
  storage.storageServer = ss;

  StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0);
  storageStepEnterAccount.isUnlocked = true;
  /*
  storage.save(callback:
      (isValid){
        print(isValid);
      });

  storage.load(callback:
  (isValid, object){
    print(isValid);
    print(object);
  });
  */
}

/*
* To load from disc previously stored values
*/
void loadDatabase({Function callbackStatus})
{
  Storage storage = new Storage();
  storage.load(callback: (isAlreadyUpdated, isValid){
    if (callbackStatus != null)
      callbackStatus(isAlreadyUpdated, isValid);
  });
}

class PassId extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    fillDatabase();
    loadDatabase();

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
            home: PassIdWidget()));
  }
}

class PassIdWidget extends StatefulWidget {
  @override
  _PassIdWidgetState createState() => _PassIdWidgetState();
}

class _PassIdWidgetState extends State<PassIdWidget>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    SystemChrome.setEnabledSystemUIOverlays([]); // hide status bar
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // TODO: return to PlatformScaffold
        appBar: AppBar( //TODO: return to PlatformAppBar
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  width: 35,
                  height: 35,
                  child: Image(image: AssetImage('assets/images/passid.png'))),
              Text("  Pass"), Text("ID", style: TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.menu, size: 35.0),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Settings()));
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
            BlocProvider<StepperBloc>(
                create: (BuildContext context) => StepperBloc(maxSteps: 3))
          ],
          child:

          Scaffold(
              body: StepperForm(steps: [
            Step(
              title: StepEnterAccountHeaderForm(),
              //subtitle: Text("EOSIO Testnet", style: TextStyle(color: Color(0xFFa58157))),
              content: StepEnterAccountForm(
                  /*stepEnterAccountHeaderObj: StepEnterAccountHeaderBloc()*/),
              //isActive: true,
            ),
            Step(
              title: StepScanHeaderForm(),
              //subtitle: Text("here you can write something", style: TextStyle(color: Color(0xFFa5a057)),),
              content: StepScanForm(),
              //state: StepState.ed iting,
              //isActive: true,
            ),
            Step(
              title: Text("Attestation"),
              content: StepAttestationForm(),
              //isActive: true,
            ),
          ])),
        ));
  }
}
