import 'dart:io';
import 'dart:math';
import 'package:dmrtd/extensions.dart';
import 'package:eosio_port_mobile_app/constants/constants.dart';
import 'package:eosio_port_mobile_app/screen/nfc/authn/authn.dart';
import 'package:eosio_port_mobile_app/utils/structure.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepper.dart';
import 'package:eosio_port_mobile_app/utils/storage.dart';
import 'package:eosio_port_mobile_app/utils/logging/loggerHandler.dart' as LH;

import 'package:eosio_port_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccountHeader/stepEnterAccountHeader.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepScan/stepScanHeader/stepScanHeader.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepAttestation/stepAttestationHeader/stepAttestationHeader.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepReview/stepReview.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepReview/stepReviewHeader/stepReviewHeader.dart';
import 'package:flutter_svg/svg.dart';

import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:logging/logging.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:port/internal.dart';
import 'package:port/port.dart';

import '../flushbar.dart';

GlobalKey<ScaffoldState> _SCAFFOLD_KEY = GlobalKey<ScaffoldState>();


/*
 * PortStepperScreen
 * - this widget creates another layer - because of dynamic link loading
 *
 */

class PortStepperScreen extends StatefulWidget {
  @override
  _PortStepperScreen createState() => _PortStepperScreen();
}

class _PortStepperScreen extends State<PortStepperScreen> with TickerProviderStateMixin {


  @override
  Widget build(BuildContext context) {
    return Container(child: PortStepperWidget());
  }
}

///*****************************************************************************
///
/// PortStepperWidget
///
///****************************************************************************/

class PortStepperWidget extends StatefulWidget {
  @override
  _PortStepperWidgetState createState() => _PortStepperWidgetState();
}

class _PortStepperWidgetState extends State<PortStepperWidget> with TickerProviderStateMixin {
  final _log = Logger("main");


  void checkConnection(BuildContext context) async {
    try {
      Storage storage = Storage();
      ServerCloud? serverCloud = storage.outsideCall.isOutsideCall?
      ServerCloud(name: "TemporaryServer", host: storage.outsideCall.getStructV1()!.host.host):
      storage.getServerCloudSelected(networkTypeServer: NetworkTypeServer.MAIN_SERVER);

      if (serverCloud == null)
        throw Exception("ServerCloud (main server) is empty. Without server you cannot check passport trust chain.");

      final httpClient = ServerSecurityContext.getHttpClient(
          timeout: Duration(seconds: serverCloud.timeoutInSeconds))
        ..badCertificateCallback = badCertificateHostCheck;

      PortClient client =  PortClient(serverCloud.host, httpClient: httpClient);
      client.onConnectionError = (SocketException e) async {
        throw JRPClientError("Cannot connect to server.");
      };
      await client.ping(Random().nextInt(0xffffffff));
    } catch (e) {
      _log.error(e);
      showFlushbar(context, "Connection", "Cannot connect to server. Check internet connection.", Icons.info);
    }
  }

  void initState(){
    super.initState();
    initializeDateFormatting();

    //clean old logger handler
    Logger.root.level = Level.ALL;
    LH.LoggerHandler loggerHandler = LH.LoggerHandler();
    loggerHandler.cleanLegacyLogs();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  bool _moveToIndexScreen(BuildContext context){
    Navigator.popUntil(context, ModalRoute.withName("/"));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    _SCAFFOLD_KEY = GlobalKey<ScaffoldState>();

    //if there is no connection show flushbar
    checkConnection(context);

    Storage storage = Storage();
    StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0) as StepDataEnterAccount;
    StepDataAttestation stepDataAttestation = storage.getStorageData(2) as StepDataAttestation;

    return PlatformScaffold(
        key: _SCAFFOLD_KEY,
        appBar: PlatformAppBar(
          automaticallyImplyLeading: true,
          title:
          Container(
            //color: Colors.green,
            child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              /*Container(
                  //color: Colors.cyan,
                  width: 35,
                  height: 35,
                  child: Image(image: AssetImage('assets/images/port.png'))),*/
              Container(
                  margin: EdgeInsets.only(left: 0),
                  width: 50,
                  height: 35,
                  child: SvgPicture.asset(
                      'assets/images/port_text_white.svg',
                      semanticsLabel: 'Port text'),
                      ),
              //Text("     Port",
              //    style: TextStyle(color: Colors.white)),
            ],
          ),
          )
        ),
        body: WillPopScope (
    onWillPop: () async {
      return _moveToIndexScreen(context);
    },
    child:MultiBlocProvider(
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
                  GestureType.onPanUpdateRightDirection
                ],
                child:Scaffold(
                  //resizeToAvoidBottomInset: false,
                    body:Column(

                        children: <Widget>[
                          //WarningBar(outsideCall: storage.outsideCall),
                          new Expanded(child: StepperForm())
                        ])
                )
            ))
      )
    );
  }
}
