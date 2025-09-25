import 'package:port_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:port_mobile_app/screen/qr/structure.dart';
import 'package:port_mobile_app/screen/requestType.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import "package:port_mobile_app/screen/main/stepper/stepReview/stepReview.dart";
import "package:port_mobile_app/screen/main/stepper/stepper.dart";
import 'package:flutter/cupertino.dart';
import 'package:port_mobile_app/utils/size.dart';
import 'package:port_mobile_app/screen/nfc/efdg1_dialog.dart';
import 'package:port_mobile_app/screen/nfc/noEfdg1Dialog.dart';
import 'package:port_mobile_app/screen/theme.dart';
import 'package:flutter/services.dart';
import 'package:port_mobile_app/screen/dots.dart';
import 'package:port_mobile_app/utils/storage.dart';


class StepReviewForm extends StatefulWidget {


  StepEnterAccountForm() {}

  @override
  _StepReviewFormState createState() => _StepReviewFormState();
}

Widget bufferState(BuildContext context){
  double marginOnRight = MediaQuery.of(context).size.width;
  double percentageMarginOnRight = 0.09;
  return Padding(
      padding: EdgeInsets.all(0.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 30),
            Container(
              margin: EdgeInsets.only(right: marginOnRight * percentageMarginOnRight),
                child:Dots(numberOfDots: 3))
      ]
    )
  );
}

Widget noConnectionState(BuildContext context){
  return Padding(
      padding: EdgeInsets.all(0.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SelectableText("no connection..."),
            const SizedBox(height: 20),
          ]
      )
  );
}

Widget successfullySend(BuildContext context,
                        RequestType requestType,
                        String transactionId,
                        String rawData) {
  String successText = AuthenticatorActions[requestType]['TEXT_ON_SUCCESS'];


  return Padding(
      padding: EdgeInsets.all(0.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
          Container(
              margin: EdgeInsets.only(top: 30, bottom: 50),
              width: 250,
              height: 50,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 36),
              )),
            SelectableText(successText),
            const SizedBox(height: 20),
            /*if (isPublishedOnChain)
            CustomCardShowHide("Transaction ID",
              transactionId,
                actions: [
                  PlatformDialogAction(
                    child: Text('Copy'),
                    onPressed: () {
                      showFlushbar(context, "Clipboard", "Item was copied to clipboard.", Icons.info);
                      Clipboard.setData(ClipboardData(text: transactionId));
                    },
                  )
                ]),*/
            //const SizedBox(height: 4),
            /*CustomCardShowHide("Raw Data",
                rawData,
                actions: [
                  PlatformDialogAction(
                    child: Text('Copy'),
                    //color: Color(0xFFa58157),
                    onPressed: () {
                      showFlushbar(context, "Clipboard", "Item was copied to clipboard.", Icons.info);
                      Clipboard.setData(ClipboardData(text: rawData));
                    },
                  )
                ]),*/
          ]));
}

class _StepReviewFormState extends State<StepReviewForm> {
  

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(StepReviewForm oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Widget getText(BuildContext context, RequestType requestType, OutsideCallV0dot2 outsideCall)
  {
    bool isPublishedOnChain = AuthenticatorActions[requestType]['IS_PUBLISHED_ON_CHAIN'];
    return Align(
        alignment: Alignment.centerLeft,
        child:
        Text(
      'Review what data will be sent to ' +
          (outsideCall.isOutsideCall
              ? outsideCall.getStructV2()!.host.toString()
              : ( isPublishedOnChain?'the blockchain.': 'the server.')),
      style: TextStyle(
          color: AndroidThemeST()
              .getValues()
              .themeValues["STEPPER"]["STEP_TAP"]
          ["COLOR_TEXT"]),
    ));
  }

  (bool includeDG1, bool includeDG2) includeDG1OrDG2ifExists(Storage storage) {
    QRserverStructure? qRserverStructure = storage.outsideCall.getStructV2();
    if (qRserverStructure == null) {
      return (false, false);
    }
    return (qRserverStructure.includeDG1, qRserverStructure.includeDG2);
  }


  @override
  Widget build(BuildContext context) {
    final stepReviewBloc = BlocProvider.of<StepReviewBloc>(context);
    StepperBloc stepperBloc = BlocProvider.of<StepperBloc>(context);

    RequestType requestTypeNoDialog = RequestType.ATTESTATION_REQUEST;
    Storage storage = Storage();
    var (includeDG1, includeDG2) = includeDG1OrDG2ifExists(storage);
    if (includeDG1 && includeDG2) {
      requestTypeNoDialog = RequestType.ATTESTATION_REQUEST_WITH_DG1_AND_DG2;
    }
    else if (includeDG1) {
      requestTypeNoDialog = RequestType.ATTESTATION_REQUEST_WITH_DG1;
    }
    return BlocBuilder(
        bloc: stepReviewBloc,
        builder: (BuildContext context, StepReviewState state) {
          return Container(
              width: CustomSize.getMaxWidth(context, STEPPER_ICON_PADDING),
              child: Form(
                  autovalidateMode: AutovalidateMode.always,
                  child: Column(
                    children: <Widget>[
                      if (state is StepReviewWithoutDataState)
                        getText(context, state.requestType, state.outsideCall),
                      if (state is StepReviewWithoutDataState)
                        NoEfDG1Dialog(
                          requestType: requestTypeNoDialog,
                          authType: state.authType,
                          rawData: state.rawData,
                          actions: [
                            PlatformTextButton(
                              child: Text('Send', style: TextStyle(color: Colors.white)),
                              color: Color(0xFFa58157),
                              //iosFilled: (_) => CupertinoFilledButtonData(),
                              onPressed: () {
                                stepReviewBloc
                                    .add(StepReviewEmptyEvent());
                                stepperBloc.isReviewLocked = true;
                                state.sendData(true);
                              },
                            )
                          ],
                        ),

                      if (state is StepReviewBufferState)
                        bufferState(context),
                      if(state is StepReviewNoConnectionState)
                        noConnectionState(context),
                      if (state is StepReviewWithDataState)
                        getText(context, state.requestType, state.outsideCall),
                      if (state is StepReviewWithDataState)
                        EfDG1Dialog(
                            context: context,
                            dg1: state.dg1,
                            message: state.msg,
                            rawData: state.rawData,
                            actions: [
                              PlatformTextButton(
                                child: Text('Send'),
                                color: Color(0xFFa58157),
                                //iosFilled: (_) => CupertinoFilledButtonData(),
                                onPressed: () {
                                  stepReviewBloc
                                      .add(StepReviewEmptyEvent());
                                  stepperBloc.isReviewLocked = true;
                                  state.sendData(true);
                                },
                              )
                            ]),
                      if (state is StepReviewCompletedState)
                        successfullySend(context, state.requestType, state.transactionID,
                            state.rawData)
                    ],
                  )));
        });
  }
}
