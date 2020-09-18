import 'package:eosio_passid_mobile_app/screen/nfc/authn/authn.dart';
import 'package:eosio_passid_mobile_app/screen/requestType.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import "package:eosio_passid_mobile_app/screen/main/stepper/stepReview/stepReview.dart";
import "package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart";
import 'package:flutter/cupertino.dart';
import 'package:eosio_passid_mobile_app/utils/size.dart';
import 'package:eosio_passid_mobile_app/screen/nfc/authn/authn.dart';
import 'package:eosio_passid_mobile_app/screen/nfc/efdg1_dialog.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';

class StepReviewForm extends StatefulWidget {
  StepEnterAccountForm() {}

  @override
  _StepReviewFormState createState() => _StepReviewFormState();
}

Widget successfullySend(RequestType requestType, String transactionId, String rawData)
{
  String successText =  AuthenticatorActions[requestType]['TEXT_ON_SUCCESS'];

  return Align(
      alignment: Alignment.centerLeft,
      child:Text(successText,
        style: TextStyle(color: AndroidThemeST().getValues().themeValues["STEPPER"]
        ["STEP_TAP"]["COLOR_TEXT"]),
      ));
}
class _StepReviewFormState extends State<StepReviewForm> {

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
                      if (state is StepReviewWithDataState)
                        Align(
                            alignment: Alignment.centerLeft,
                            child:Text('Review what data will be send to ' + (state.outsideCall.isOutsideCall && false ? state.outsideCall.requestedBy : 'the blockchain.'),
                              style: TextStyle(color: AndroidThemeST().getValues().themeValues["STEPPER"]
                              ["STEP_TAP"]["COLOR_TEXT"]),
                            )),
                      if (state is StepReviewWithDataState)
                        EfDG1Dialog(
                            context: context,
                            dg1: state.dg1,
                            message: state.msg,
                            actions:  [
                              PlatformButton(
                                child: Text('Send'),
                                color: Color(0xFFa58157),
                                //iosFilled: (_) => CupertinoFilledButtonData(),
                                onPressed: () {
                                  stepReviewBloc.add(StepReviewWithoutDataEvent());
                                  stepperBloc.isReviewLocked = true;
                                  state.sendData(true);
                                },
                              )
                            ]),
                      if (state is StepReviewCompletedState)
                        successfullySend(state.requestType, state.transactionID, state.rawData)
                    ],
                  )
              )
            );
          }
        );
    }
}
