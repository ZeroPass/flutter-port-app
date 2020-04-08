import 'package:eosio_passid_mobile_app/settings/settings.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:logging/logging.dart';
void main() => runApp(MyApp());


void fillDatabase()
{
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.loggerName} ${record.level.name}: ${record.time}: ${record.message}');
  });

  print("fill database");
  Storage storage = new Storage();

  //to call it just one time
  if(storage.storageNodes().length > 0)
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


  //TODO:write your passport data - debug mode
  StepDataScan storageStepScan = storage.getStorageData(1);
  storageStepScan.documentID = "";
  storageStepScan.birth = DateTime(2000, 1,1);
  storageStepScan.validUntil = DateTime(2100, 1,1);
}

class MyApp extends StatelessWidget {

  //StepEnterAccountHeaderForm temp = StepEnterAccountHeaderForm();
  //final stepEnterAccountHeaderBloc = BlocProvider.of<StepEnterAccountHeaderBloc>(context);

  // This widget is the root of your application.
  /*final List<Step> steps = [
    Step(
      title: StepEnterAccountHeaderForm(),
      //subtitle: Text("EOSIO Testnet", style: TextStyle(color: Color(0xFFa58157))),
      content: StepEnterAccountForm(),
      isActive: true,
    ),
    Step(
      title: Text("Scan"),
      //subtitle: Text("here you can write something", style: TextStyle(color: Color(0xFFa5a057)),),
      content: BlocProvider<StepScanBloc>(
          create: (context) => StepScanBloc(), child: StepScanForm(temp: 1)),
      //state: StepState.ed iting,
      isActive: true,
    ),
    Step(
      title: Text("Attestation"),
      content: Text("Hello World!"),
      isActive: true,
    ),
  ];*/

  @override
  Widget build(BuildContext context) {
    fillDatabase();


    return PlatformProvider(
        //initialPlatform: initialPlatform,
        builder: (BuildContext context) => PlatformApp(
            title: 'PassID',
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
            ],
            android: (_) => new MaterialAppData(
                theme: new AndroidTheme().getLight(),
                darkTheme: new AndroidTheme().getDark()),
            ios: (_) => new CupertinoAppData(
                    theme: new CupertinoThemeData(
                  primaryColor: Colors.grey,
                )),
            home: PlatformScaffold(


              /*

              Builder(
                builder: (context) => RaisedButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(
                                builder: (context) => SelectUserType()));
                      },
                      child: Text('Registrese'),
                    ),
              ),
               */
                iosContentPadding: true,
                appBar: PlatformAppBar(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                    Builder( builder: (context) =>
                        InkWell(
                          onTap: () {
                            //open settings panel
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => Settings()));
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Icon(Icons.menu, )
                            ],
                          ),
                        )),
                      Text(" PassID")
                    ],
                  ),


                  trailingActions: <Widget>[
                    PlatformIconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(context.platformIcons.share),
                      onPressed: () {},
                    ),
                  ],
                ),

                    body: MultiBlocProvider(
                      providers:[
                        BlocProvider<StepEnterAccountHeaderBloc>(
                            create: (BuildContext context) => StepEnterAccountHeaderBloc()
                        ),
                        BlocProvider<StepScanHeaderBloc>(
                            create: (BuildContext context) => StepScanHeaderBloc()
                        ),
                        BlocProvider<StepEnterAccountBloc>(
                            create: (BuildContext context) => StepEnterAccountBloc()
                        ),
                        BlocProvider<StepScanBloc>(
                            create: (BuildContext context) => StepScanBloc()
                        ),
                        BlocProvider<StepAttestationBloc>(
                            create: (BuildContext context) => StepAttestationBloc()
                        ),
                        BlocProvider<StepperBloc>(
                            create: (BuildContext context) => StepperBloc(maxSteps: 3)
                        )
                        ],
                  child: Scaffold(body:StepperForm(steps:

                  [
                    Step(
                      title: StepEnterAccountHeaderForm(),
                      //subtitle: Text("EOSIO Testnet", style: TextStyle(color: Color(0xFFa58157))),
                      content: StepEnterAccountForm(/*stepEnterAccountHeaderObj: StepEnterAccountHeaderBloc()*/),
                      //isActive: true,
                    ),
                    Step(
                      title: StepScanHeaderForm(),
                      //subtitle: Text("here you can write something", style: TextStyle(color: Color(0xFFa5a057)),),
                      content:  StepScanForm(),
                      //state: StepState.ed iting,
                      //isActive: true,
                    ),
                    Step(
                      title: Text("Attestation"),
                      content: StepAttestationForm(),
                      //isActive: true,
                    ),
                  ]

                  )),
                ))));

  }
}
