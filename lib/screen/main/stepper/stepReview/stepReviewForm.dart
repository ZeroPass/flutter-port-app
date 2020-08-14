import 'package:eosio_passid_mobile_app/screen/nfc/authn/authn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:eosio_passid_mobile_app/screen/main/stepper/stepReview/stepReview.dart";
import "package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart";
import 'package:flutter/cupertino.dart';
import 'package:eosio_passid_mobile_app/utils/size.dart';
import 'package:eosio_passid_mobile_app/screen/nfc/authn/authn.dart';

class StepReviewForm extends StatefulWidget {
  StepEnterAccountForm() {}

  @override
  _StepReviewFormState createState() => _StepReviewFormState();
}

class _StepReviewFormState extends State<StepReviewForm> {

  @override
  Widget build(BuildContext context) {
    final stepReviewBloc = BlocProvider.of<StepReviewBloc>(context);
    return BlocBuilder(
        bloc: stepReviewBloc,
        builder: (BuildContext context, StepReviewState state) {
          return Container(
              width: CustomSize.getMaxWidth(context, STEPPER_ICON_PADDING),
              child: Form(
                  autovalidate: true,
                  child: AuthnForm() /*BlocBuilder(
                      bloc: authnBloc,
                      builder: (BuildContext context, AuthnState state) {
                        //return Container(child:Authn());
                      }*/
              )
            );
          }
        );
    }
}
