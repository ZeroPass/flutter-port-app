import 'package:dmrtd/src/extension/logging_apis.dart';
import 'package:eosio_port_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:eosio_port_mobile_app/screen/requestType.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_cache_builder.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import "package:eosio_port_mobile_app/screen/main/stepper/stepReview/stepReview.dart";
import "package:eosio_port_mobile_app/screen/main/stepper/stepper.dart";
import 'package:flutter/cupertino.dart';
import 'package:eosio_port_mobile_app/utils/size.dart';
import 'package:eosio_port_mobile_app/screen/nfc/efdg1_dialog.dart';
import 'package:eosio_port_mobile_app/screen/nfc/noEfdg1Dialog.dart';
import 'package:eosio_port_mobile_app/screen/theme.dart';
import 'package:flutter/services.dart';
import 'package:eosio_port_mobile_app/screen/flushbar.dart';
import 'package:eosio_port_mobile_app/screen/dots.dart';
import 'package:logging/logging.dart';
import 'package:rive/rive.dart';


final _log = Logger('StepReviewForm');

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
    String rawData,
    Artboard riveArtboard,
    RiveAnimationController animationController) {
  String successText = AuthenticatorActions[requestType]['TEXT_ON_SUCCESS'];
  bool isPublishedOnChain = AuthenticatorActions[requestType]['IS_PUBLISHED_ON_CHAIN'];


  return Padding(
      padding: EdgeInsets.all(0.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
          GestureDetector(
          onTap: (){
            riveArtboard.addController(animationController = SimpleAnimation('checkmarks'));
          },
            child:Container(
                margin: EdgeInsets.only(top: 30, bottom: 50),
                width: 250,
                height: 50,
                child: Rive(artboard: riveArtboard, alignment: Alignment.centerLeft),
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
  late Artboard _riveArtboard;
  late RiveAnimationController _animationController;

  @override
  void initState() {
    rootBundle.load('assets/anim/checkmarks.riv').then(
          (data) async {
            try {
              // Load the RiveFile from the binary data.
              final file = RiveFile.import(data);
              final artboard = file.mainArtboard;

              artboard.addController(
                  _animationController = SimpleAnimation('checkmarks'));
                  setState(() => _riveArtboard = artboard);
            }
            catch(exception){
              _log.debug("Problem occured when loading rive file: " + exception.toString());
            }
      },
    );

    super.initState();
  }

  @override
  void didUpdateWidget(StepReviewForm oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Widget getText(BuildContext context, RequestType requestType, OutsideCallV0dot1 outsideCall)
  {
    bool isPublishedOnChain = AuthenticatorActions[requestType]['IS_PUBLISHED_ON_CHAIN'];
    return Align(
        alignment: Alignment.centerLeft,
        child:
        Text(
      'Review what data will be send to ' +
          (outsideCall.isOutsideCall
              ? outsideCall.getStructV1()!.host.toString()
              : ( isPublishedOnChain?'the blockchain.': 'the server.')),
      style: TextStyle(
          color: AndroidThemeST()
              .getValues()
              .themeValues["STEPPER"]["STEP_TAP"]
          ["COLOR_TEXT"]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final stepReviewBloc = BlocProvider.of<StepReviewBloc>(context);
    StepperBloc stepperBloc = BlocProvider.of<StepperBloc>(context);
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
                          requestType: RequestType.ATTESTATION_REQUEST,
                          authType: state.authType,
                          rawData: state.rawData,
                          actions: [
                            PlatformButton(
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
                              PlatformButton(
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
                            state.rawData, _riveArtboard, _animationController)
                    ],
                  )));
        });
  }
}
