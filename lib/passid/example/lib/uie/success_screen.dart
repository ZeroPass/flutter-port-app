//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import "package:flare_flutter/flare_actor.dart";
import "package:flare_flutter/flare_cache_builder.dart";
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passid/passid.dart';
import 'package:passide/uie/uiutils.dart';
import 'authn_screen.dart';

class SuccessScreen extends StatelessWidget {
  final AuthnAction action;
  final UserId uid;
  final String serverMsg;

  final _successCheck =
      AssetFlare(bundle: rootBundle, name: 'assets/anim/success_check.flr');

  SuccessScreen(this.action, this.uid, this.serverMsg);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Container(
            child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Card(
                    child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text((action == AuthnAction.register ? 'Sign up' : 'Login') + ' succeeded',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24)),
                        Expanded(
                            flex: 30,
                            child: FlareCacheBuilder(
                              [_successCheck],
                              builder: (BuildContext context, bool isWarm) {
                                return !isWarm
                                    ? Container()
                                    : FlareActor.asset(
                                        _successCheck,
                                        alignment: Alignment.center,
                                        fit: BoxFit.cover,
                                        animation: 'Untitled',
                                      );
                              },
                            )),
                        //Spacer(flex: 2),
                        Row(children: <Widget>[
                          Expanded(
                              child: Text('Server says:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)))
                        ]),
                        Text(
                          serverMsg,
                          style: TextStyle(fontSize: 18)),
                        Spacer(flex: 5),
                        makeButton(
                            context: context,
                            text: 'MAIN MENU',
                            onPressed: () => Navigator.maybePop(context)
                        ),
                        const SizedBox(height: 20),
                                            Row(children: <Widget>[
                          Text('UID: '),
                          Expanded(
                              child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Text(uid.toString())))
                        ]),
                      ]),
                )))));
  }
}
