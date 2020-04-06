//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.

import 'package:flutter/material.dart';
import 'package:passide/uie/uiutils.dart';

Widget HomePage(
    BuildContext context, Function onSignupPressed, Function onLoginPressed) {
  return Container(
    height: MediaQuery.of(context).size.height,
    decoration: BoxDecoration(
      color: Colors.deepPurple,
      image: DecorationImage(
        colorFilter:
            ColorFilter.mode(Colors.black.withOpacity(0.13), BlendMode.dstATop),
        image: AssetImage('assets/images/mountains.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        settingsButton(context, iconSize: 40.0),
        Container(
          padding: EdgeInsets.only(top: 100.0),
          child: Center(
            child: Image(
              image: AssetImage('assets/images/passid.png'),
              fit: BoxFit.scaleDown,
              height: 70,
              width: 70,
              filterQuality: FilterQuality.high,
            )
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Pass',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.0,
                ),
              ),
              Text(
                'IDe',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 150.0),
          alignment: Alignment.center,
          child: Row(
            children: <Widget>[
              Expanded(
                child: OutlineButton(
                  borderSide: BorderSide(
                    width: 1,
                    color: Theme.of(context).primaryColor,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  color: Colors.redAccent,
                  highlightedBorderColor: Theme.of(context).primaryColor,
                  onPressed: onSignupPressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 20.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'SIGN UP',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
          alignment: Alignment.center,
          child: Row(
            children: <Widget>[
              Expanded(
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  color: Theme.of(context).primaryColor,
                  onPressed: onLoginPressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 20.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'LOGIN',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}