import 'package:flutter/material.dart';
import 'package:eosio_port_mobile_app/screen/customCard.dart';
import 'package:eosio_port_mobile_app/screen/requestType.dart';

import 'authn/authn.dart';


class NoEfDG1Dialog extends StatefulWidget {
  final RequestType requestType;
  final AuthenticationType authType;
  final String rawData;
  final List<Widget> actions;

  NoEfDG1Dialog(
      {required this.requestType,
        required this.authType,
        required this.rawData,
        required this.actions});

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
        height: MediaQuery.of(context).size.height * 1.0,
        child: Padding(
            padding: EdgeInsets.all(0.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 14),
                  CustomCard("Authn Data", [
                    for (String item in AuthenticatorActions[widget.requestType]["DATA_IN_REVIEW"])
                      if (!(widget.authType != AuthenticationType.ActiveAuthentication && (item.contains("Passport Signature") || item.contains("Passport Public Key (EF.DG15)"))))
                        CardItem('• ' + item, null)
                        ,
                  ]),
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
