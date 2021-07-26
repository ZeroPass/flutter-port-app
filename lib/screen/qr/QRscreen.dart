import 'package:eosio_port_mobile_app/screen/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:eosio_port_mobile_app/screen/qr/readQR.dart';

class QRscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return QRscreenBody();
  }
}

class QRscreenBody extends StatefulWidget {
  @override
  _QRscreenBodyState createState() => _QRscreenBodyState();
}

class _QRscreenBodyState extends State<QRscreenBody> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    showNavigationBar();
    return PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text("Scanning QR code"),
        ),
        body: Container(child: Form(key: _formKey, child: ReadQR())));
  }
}
