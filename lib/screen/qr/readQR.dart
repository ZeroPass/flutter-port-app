import 'dart:convert';
import 'dart:io';

import 'package:eosio_port_mobile_app/screen/index/index.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepperBloc.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:logging/logging.dart';
import 'package:dmrtd/src/extension/logging_apis.dart';
import 'package:eosio_port_mobile_app/screen/customButton.dart';
import 'package:eosio_port_mobile_app/screen/theme.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_port_mobile_app/screen/qr/structure.dart';
import 'package:eosio_port_mobile_app/screen/alert.dart';
import 'package:eosio_port_mobile_app/utils/storage.dart';

class ReadQR extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReadQRState();

  static void saveToDatabase(QRserverStructure data){
    Logger("QRstrucutre.saveToDatabase").debug("Saving data to database : ${data.toString()}");
    Storage storage = Storage();

    //set request type
    StepDataAttestation stepDataAttestation = storage.getStorageData(2) as StepDataAttestation;
    stepDataAttestation.requestType = data.requestType;

    //set request as outside call
    storage.outsideCall = OutsideCallV0dot1();
    storage.outsideCall.setV0dot1(qRserverStructure:
    QRserverStructure(accountID: data.accountID, requestType: data.requestType, host: data.host));
  }
}

class _ReadQRState extends State<ReadQR> {
  final _log = Logger("QRstrucutre");
  Barcode? result;
  QRViewController? controller;
  late bool isCaptured; //qr is detected, reading in progress
  GlobalKey qrKey = GlobalKey<FormState>(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    this.isCaptured = false;
    return Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  //if (result != null)
                  //  Text(
                  //      'Barcode Type: ${describeEnum(result.format)}   Data: ${result.code}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        //flex: 1,
                        margin: EdgeInsets.only(left: 8.0, right: 8.0),
                          //width:  MediaQuery.of(context).size.width / 2,
                        child: PlatformButton(
                            materialFlat: (_, __)  => MaterialFlatButtonData(minWidth: MediaQuery.of(context).size.width / 2.1, color: Theme.of(context).buttonColor),
                            cupertino: (_, __) => CupertinoButtonData(minSize: MediaQuery.of(context).size.width / 2.1),
                            child: //Text('Turn on flash'),
                                  FutureBuilder(
                                    future: controller?.getFlashStatus(),
                                    builder: (context, snapshot) {
                                      return Text('Flashlight: ${snapshot.data !=null && (snapshot).data == true ? 'off':'on'}');
                                  },
                                  ),
                            onPressed: () async {
                              await controller?.toggleFlash();
                              setState(() {});
                            },
                          )
                      ),
                      Container(
                        //flex: 1,
                        //width:  MediaQuery.of(context).size.width / 2,
                        margin: EdgeInsets.only(left: 8.0, right: 8.0),
                        child:
                            PlatformButton(
                              materialFlat: (_, __)  => MaterialFlatButtonData(minWidth: MediaQuery.of(context).size.width / 2.1, color: Theme.of(context).buttonColor),
                              cupertino: (_, __) => CupertinoButtonData(minSize: MediaQuery.of(context).size.width / 2.1),
                              child: Text("Flip camera"),
                              onPressed: () async {
                                await controller?.flipCamera();
                                setState(() {});
                              },
                            )
                      )
                    ],
                  ),
                ],
              ),
            )
        ],
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      //overlayMargin: EdgeInsets.fromLTRB(90, 70, 50, 30),
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: AndroidThemeST().getValues().themeValues["QR_SCREEN"]["COLOR_FOCUS_BORDER"],
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  Future<bool> readQR(Barcode scanData) async{
    try{
      QRserverStructure? qr = QRserverStructure.parseDynamicLink(scanData.code?.replaceAll('\n', "").replaceAll(' ', '') ?? '');
      if (qr == null)
        throw Exception("Error when parsing dynamic link");

      ReadQR.saveToDatabase(qr);
      return Future.value(true);
    }
    catch(e){
      print ("Error occurred when parsing QR data: $e");
      _log.debug("ror occurred when parsing QR data: $e");
      return Future.value(false);
    }
  }
  void redirect(){
    _log.debug("Redirecting to new screen. Also clearing stack of screens.");
    //Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    Navigator.pushNamed(context, '/home');
  }


  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) async {
      controller.stopCamera();
      //setState(() {
        try {
          this.isCaptured = true;
          bool continueProcess = await this.readQR(scanData);


          continueProcess ? redirect(): controller.resumeCamera();

        }
        catch (e){
          print ("Error occurred when parsing QR data: $e");
          _log.debug("Error occurred when parsing QR data: $e");
          controller.resumeCamera();
        }
      //});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}