import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:eosio_passid_mobile_app/screen/nfc/authn/authn.dart';
import 'package:eosio_passid_mobile_app/screen/requestType.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import "package:eosio_passid_mobile_app/screen/main/stepper/stepReview/stepReview.dart";
import "package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart";
import 'package:flutter/cupertino.dart';
import 'package:eosio_passid_mobile_app/utils/size.dart';
import 'package:eosio_passid_mobile_app/screen/customCard.dart';
import 'package:eosio_passid_mobile_app/screen/customCardShowHide.dart';
import 'package:eosio_passid_mobile_app/screen/nfc/efdg1_dialog.dart';
import 'package:eosio_passid_mobile_app/screen/nfc/noEfdg1Dialog.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import 'package:flutter/services.dart';
import 'package:eosio_passid_mobile_app/screen/flushbar.dart';

class StepReviewForm extends StatefulWidget {
  StepEnterAccountForm() {}

  @override
  _StepReviewFormState createState() => _StepReviewFormState();
}

Widget successfullySend(BuildContext context,
    RequestType requestType, String transactionId, String rawData) {
  String successText = AuthenticatorActions[requestType]['TEXT_ON_SUCCESS'];
  bool isPublishedOnChain = AuthenticatorActions[requestType]['IS_PUBLISHED_ON_CHAIN'];

  return Padding(
      padding: EdgeInsets.all(0.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SelectableText(successText),
            const SizedBox(height: 20),
            if (isPublishedOnChain)
            CustomCardShowHide("• Transaction ID",
              transactionId,
                actions: [
                  PlatformDialogAction(
                    child: Text('Copy'),
                    onPressed: () {
                      showFlushbar(context, "Clipboard", "Item was copied to clipboard.");
                      Clipboard.setData(ClipboardData(text: transactionId));
                    },
                  )
                ]),
            //const SizedBox(height: 4),
            CustomCardShowHide("• Raw Data",
                rawData,
                actions: [
                  PlatformDialogAction(
                    child: Text('Copy'),
                    //color: Color(0xFFa58157),
                    onPressed: () {
                      showFlushbar(context, "Clipboard", "Item was copied to clipboard.");
                      Clipboard.setData(ClipboardData(text: rawData));
                    },
                  )
                ]),
          ]));
}

class _StepReviewFormState extends State<StepReviewForm> {

  Widget getText(BuildContext context, RequestType requestType, OutsideCall outsideCall)
  {
    bool isPublishedOnChain = AuthenticatorActions[requestType]['IS_PUBLISHED_ON_CHAIN'];
    return Align(
        alignment: Alignment.centerLeft,
        child:
        Text(
      'Review what data will be send to ' +
          (outsideCall.isOutsideCall && false
              ? outsideCall.requestedBy
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
                  autovalidate: true,
                  child: Column(
                    children: <Widget>[
                      if (state is StepReviewWithoutDataState)
                        getText(context, state.requestType, state.outsideCall),
                      if (state is StepReviewWithoutDataState)
                        NoEfDG1Dialog(
                          requestType: RequestType.ATTESTATION_REQUEST,
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
                            state.rawData)
                    ],
                  )));
        });
  }
}
