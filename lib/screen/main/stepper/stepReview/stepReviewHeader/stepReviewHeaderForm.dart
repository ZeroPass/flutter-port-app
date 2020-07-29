import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepReview/stepReviewHeader/stepReviewHeader.dart';
import 'package:flutter/cupertino.dart';
import "package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart";
import 'package:eosio_passid_mobile_app/utils/size.dart';

class StepReviewHeaderForm extends StatefulWidget {
  StepReviewHeaderForm({Key key}) : super(key: key);

  @override
  _StepReviewHeaderFormState createState() => _StepReviewHeaderFormState();
}

class _StepReviewHeaderFormState extends State<StepReviewHeaderForm> {
  _StepReviewHeaderFormState({Key key});

  @override
  Widget build(BuildContext context) {
    final stepReviewHeaderBloc =
        BlocProvider.of<StepReviewHeaderBloc>(context);
    return BlocBuilder(
      bloc: stepReviewHeaderBloc,
      builder: (BuildContext context, StepReviewHeaderState state) {
        return Container(
            width: CustomSize.getMaxWidth(context, STEPPER_ICON_PADDING),
            child: Text ("Review")
        );
      },
    );
  }
}
