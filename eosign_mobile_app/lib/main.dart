import 'package:eosign_mobile_app/settings/settings.dart';
import 'package:eosign_mobile_app/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eosign_mobile_app/screen/main/stepper/stepper.dart';
import 'package:eosign_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:eosign_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:eosign_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosign_mobile_app/screen/theme.dart';


void main() => runApp(MyApp());


void fillDatabase()
{
  print("fill database");
  Storage storage = new Storage();

  //to call it just one time
  if(storage.storageNodes().length > 0)
    return;

  print("---------------------------------------------------in fill datatbase");
  List<StorageNode> nodes = storage.storageNodes();
  StorageNode sn = new StorageNode(name: "Kylin testnet", host: "kylin.eosnode.io", port: 443, isEncryptedEndpoint: true, networkType: NetworkType.KYLIN, chainID: "abcedfdsaffdas");
  nodes.add(sn);

  sn = new StorageNode(name: "EOSIO testnet", host: "eosio.eosnode.io", port: 443, isEncryptedEndpoint: true, networkType: NetworkType.EOSIO_TESTNET, chainID: "fsadfsdafasdfasd");
  nodes.add(sn);

  sn = new StorageNode(name: "Mainnet", host: "mainenet.eosnode.io", port: 443, isEncryptedEndpoint: true, networkType: NetworkType.MAINNET, chainID: "abcedfdsdfgasfsdfasdfasdaffdas");
  nodes.add(sn);

  sn = new StorageNode(name: "My rivate chain", host: "456786.eosnode.io", port: 443, isEncryptedEndpoint: true, networkType: NetworkType.CUSTOM, chainID: "abce5435345dsaffdas");
  nodes.add(sn);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final List<Step> steps = [
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
  ];

  @override
  Widget build(BuildContext context) {
    fillDatabase();
    return PlatformProvider(
        //initialPlatform: initialPlatform,
        builder: (BuildContext context) => PlatformApp(
            title: 'Flutter Platform Widgets',
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
                iosContentPadding: true,
                appBar: PlatformAppBar(
                  title: Text('PassID'),
                  trailingActions: <Widget>[
                    PlatformIconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(context.platformIcons.share),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: Scaffold(
                    body: MultiBlocProvider(
                      providers:[
                        BlocProvider<StepperBloc>(
                            create: (BuildContext context) => StepperBloc(maxSteps: steps.length)
                        ),
                        BlocProvider<StepEnterAccountBloc>(
                            create: (BuildContext context) => StepEnterAccountBloc()
                        ),
                        BlocProvider<StepEnterAccountHeaderBloc>(
                            create: (BuildContext context) => StepEnterAccountHeaderBloc()
                        )
                        ],
                  child: StepperForm(steps: steps),
                )))));

  }
}
