import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eosign_mobile_app/screen/main/stepper/stepper.dart';
import 'package:eosign_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final List<Step> steps = [
    Step(
      title: Text("Step 1"),
      //content: StepEnterAccountForm(temp: 2),
      content: BlocProvider<StepEnterAccountBloc>(
                create: (context) => StepEnterAccountBloc(),
                child: StepEnterAccountForm(temp: 1)
      ),
      isActive: true,
    ),
    Step(
      title: Text("Step 2"),
      content: Text("World!"),
      state: StepState.editing,
      isActive: true,
    ),
    Step(
      title: Text("Step 3"),
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
        android: (_) => new MaterialAppData(theme: new ThemeData(primarySwatch: Colors.grey)),
        ios: (_) => new CupertinoAppData(theme: new CupertinoThemeData(primaryColor: Colors.grey,)),
        home:
      PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text('Flutter Platform Widgets'),
        trailingActions: <Widget>[
          PlatformIconButton(
            padding: EdgeInsets.zero,
            icon: Icon(context.platformIcons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => StepperBloc(maxSteps: steps.length),
        child: StepperForm(steps: steps),
      )
    )
    )
    );




    /*MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('PassID'),
        ),
        body: BlocProvider(
          create: (context) => StepperBloc(maxSteps: steps.length),
          child: StepperForm(steps: steps),
        ),
      ),
    );*/
  }
}