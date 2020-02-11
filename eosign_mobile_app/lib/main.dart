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

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final List<Step> steps = [
    Step(
      title: StepEnterAccountHeaderForm(),
      content: BlocProvider<StepEnterAccountBloc>(
          create: (context) => StepEnterAccountBloc(),
          child: StepEnterAccountForm(temp: 1)),
      isActive: true,
    ),
    Step(
      title: Text("Step 22"),
      content: BlocProvider<StepScanBloc>(
          create: (context) => StepScanBloc(), child: StepScanForm(temp: 1)),
      //state: StepState.ed iting,
      isActive: true,
    ),
    Step(
      title: Text("Step 35"),
      content: Text("Hello World!"),
      isActive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    print("application starts");
    /* return CupertinoApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      title: 'Flutter Demo',
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: MaterialApp(*/
    /*localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],*/
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
                  title: Text('EOSPass'),
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
                        BlocProvider<StepEnterAccountHeaderBloc>(
                            create: (BuildContext context) => StepEnterAccountHeaderBloc()
                        )],
                  child: StepperForm(steps: steps),
                )))));
                /*
                * body: Scaffold(
                    body: BlocProvider(
                  create: (context) => StepperBloc(maxSteps: steps.length),
                  child: StepperForm(steps: steps),
                )))));*/
  }
}
