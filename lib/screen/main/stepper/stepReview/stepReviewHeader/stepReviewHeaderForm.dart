import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:port_mobile_app/screen/main/stepper/stepReview/stepReview.dart';
import 'package:port_mobile_app/screen/main/stepper/stepReview/stepReviewHeader/stepReviewHeader.dart';
import 'package:flutter/cupertino.dart';
import "package:port_mobile_app/screen/main/stepper/stepper.dart";
import 'package:port_mobile_app/utils/size.dart';
import 'package:port_mobile_app/screen/theme.dart';

class StepReviewHeaderForm extends StatefulWidget {
  StepReviewHeaderForm() : super();

  @override
  _StepReviewHeaderFormState createState() => _StepReviewHeaderFormState();
}

Widget deleteButton(BuildContext context) {
  final stepperBloc = BlocProvider.of<StepperBloc>(context);
  final stepReviewHeaderBloc = BlocProvider.of<StepReviewHeaderBloc>(context);
  final stepReviewBloc = BlocProvider.of<StepReviewBloc>(context);

  return ClipOval(
    child: Material(
      //color: Colors.white, // button color
      child: InkWell(
        hoverColor: Colors.black,
        splashColor: Colors.green,
        // splash color
        focusColor: Colors.green,
        highlightColor: Colors.green,
        onTap: () {
          //disable revew tab
          stepperBloc.isReviewLocked = true;

          //change state on stepper
          stepperBloc.add(StepTapped(step: stepperBloc.state.previousStep /*?? 1*/, previousStep: 0));

          //change state on step main window
          stepReviewBloc.add(StepReviewEmptyEvent());

          //change state on step header
          stepReviewHeaderBloc.add(StepReviewHeaderWithoutDataEvent());
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(Icons.remove_circle, color: AndroidThemeST().getValues().themeValues["STEPPER"]["BUTTON_DELETE"]["COLOR_BACKGROUND"])
          ],
        ),
      ),
    ),
    //),
  );
}

class _StepReviewHeaderFormState extends State<StepReviewHeaderForm> {
  _StepReviewHeaderFormState();

  @override
  Widget build(BuildContext context) {
    final stepReviewHeaderBloc =
        BlocProvider.of<StepReviewHeaderBloc>(context);
    return BlocBuilder(
      bloc: stepReviewHeaderBloc,
      builder: (BuildContext context, StepReviewHeaderState state) {
        return Container(
            width: CustomSize.getMaxWidth(context, STEPPER_ICON_PADDING),
            child: Column(children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Review"),
                    Row(children: <Widget>[
                      if (state is StepReviewHeaderWithDataState)
                        Align(
                            alignment: Alignment.centerRight,
                            child: deleteButton(context))
                    ],
                    )
                  ]
              )]
              //)
            )
        );
      },
    );
  }
}
