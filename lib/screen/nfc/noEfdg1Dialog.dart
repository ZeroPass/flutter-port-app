import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/screen/customCard.dart';
import 'package:eosio_passid_mobile_app/screen/customCardShowHide.dart';
import 'package:eosio_passid_mobile_app/screen/requestType.dart';


class NoEfDG1Dialog extends StatefulWidget {
  final RequestType requestType;
  final String rawData;
  final List<Widget> actions;

  NoEfDG1Dialog(
      {@required this.requestType,
        @required this.rawData,
        @required this.actions});

  @override
  _NoEfDG1Dialog createState() => _NoEfDG1Dialog();
}

class _NoEfDG1Dialog extends State<NoEfDG1Dialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.80,
        child: Padding(
            padding: EdgeInsets.all(0.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 14),
                  CustomCard("Authn Data", [
                    for (var item in AuthenticatorActions[widget.requestType]["DATA_IN_REVIEW"])
                      CardItem('• ' + item, null),
                  ]),
                  const SizedBox(height: 18),
                  CustomCardShowHide("Raw Data",
                      this.widget.rawData),
                  const SizedBox(height: 30),
                  Wrap(
                      alignment: WrapAlignment.spaceAround,
                      direction: Axis.horizontal,
                      runSpacing: 1,
                      spacing: 1,
                      children: <Widget>[...widget.actions])
                ])));
  }
}
