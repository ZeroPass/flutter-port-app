//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'package:dart_countries_states/country_provider.dart';
import 'package:dart_countries_states/models/alpha2_codes.dart';
import 'package:dart_countries_states/models/alpha3_code.dart';
import 'package:dart_countries_states/models/country.dart';
import 'package:flutter/material.dart';
import 'package:dmrtd/dmrtd.dart';

import '../utils.dart';
import 'uiutils.dart';

// Dialog displays MRZ data stored in file EF.DG1
Future<T> showEfDG1Dialog<T>(BuildContext context, EfDG1 dg1,
    {String message, List<Widget> actions}) {
  return EfDG1Dialog(context, dg1, message: message, actions: actions).show();
}

class EfDG1Dialog {
  final EfDG1 dg1;
  final BuildContext context;
  final String message;
  final List<Widget> actions;
  final _countryProvider = CountryProvider();
  String _issuingCountry = '';
  String _nationality = '';
  StateSetter _sheetSetter;

  EfDG1Dialog(this.context, this.dg1, {this.message, this.actions}) {
    _formatCountryCode(dg1.mrz.country).then((c) {
      if (_sheetSetter != null) {
        _sheetSetter(() => _issuingCountry = c);
      } else {
        _issuingCountry = c;
      }
    });

    _formatCountryCode(dg1.mrz.nationality).then((c) {
      if (_sheetSetter != null) {
        _sheetSetter(() => _nationality = c);
      } else {
        _nationality = c;
      }
    });
  }

  Future<T> show<T>() {
    return _showBottomSheet();
  }

  String _formatDate(DateTime date, BuildContext ctx) {
    final locale = getLocaleOf(ctx);
    return formatDate(date, locale: locale);
  }

  Future<String> _formatCountryCode(String code) async {
    try {
      Country c;
      if (code.length == 2) {
        c = await _countryProvider.getCountryByCode2(
            code2: Alpha2Code.valueOf(code));
      } else {
        c = await _countryProvider.getCountryByCode3(
            code3: Alpha3Code.valueOf(code));
      }
      return c.name;
    } catch (_) {
      return code;
    }
  }

  Future<T> _showBottomSheet<T>() {
    if (_sheetSetter != null) {
      return null;
    }

    return showModalBottomSheet(
        context: context,
        isDismissible: false,
        useRootNavigator: true,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0))),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            _sheetSetter = setState;
            return _build(context);
          });
        });
  }

  Widget _build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height - 50,
        child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(children: <Widget>[
              const SizedBox(height: 10),
              Text(
                message ?? '',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                  child: Card(
                      child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Passport Data',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                const SizedBox(height: 5),
                                Row(children: <Widget>[
                                  Expanded(
                                      child: Text(
                                    'Passport type:',
                                    style: TextStyle(fontSize: 16),
                                  )),
                                  Expanded(
                                      child: Text(dg1.mrz.documentCode,
                                          style: TextStyle(fontSize: 16)))
                                ]),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                          child: Text('Passport no.:',
                                              style: TextStyle(fontSize: 16))),
                                      Expanded(
                                          child: Text(dg1.mrz.documentNumber,
                                              style: TextStyle(fontSize: 16))),
                                    ]),
                                Row(children: <Widget>[
                                  Expanded(
                                      child: Text('Date of Expiry:',
                                          style: TextStyle(fontSize: 16))),
                                  Expanded(
                                      child: Text(
                                          _formatDate(
                                              dg1.mrz.dateOfExpiry, context),
                                          style: TextStyle(fontSize: 16)))
                                ]),
                                Row(children: <Widget>[
                                  Expanded(
                                      child: Text('Issuing Country:',
                                          style: TextStyle(fontSize: 16))),
                                  Expanded(
                                      child: Text(_issuingCountry,
                                          style: TextStyle(fontSize: 16)))
                                ]),
                                const SizedBox(height: 30),
                                Text(
                                  'Personal Data',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                const SizedBox(height: 5),
                                Row(children: <Widget>[
                                  Expanded(
                                      child: Text('Name:',
                                          style: TextStyle(fontSize: 16))),
                                  Expanded(
                                      child: Text(capitalize(dg1.mrz.firstName),
                                          style: TextStyle(fontSize: 16))),
                                ]),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                        child: Text('Last Name',
                                            style: TextStyle(fontSize: 16))),
                                    Expanded(
                                        child: Text(
                                            capitalize(dg1.mrz.lastName),
                                            style: TextStyle(fontSize: 16))),
                                  ],
                                ),
                                Row(children: <Widget>[
                                  Expanded(
                                      child: Text('Date of Birth:',
                                          style: TextStyle(fontSize: 16))),
                                  Expanded(
                                      child: Text(
                                          _formatDate(
                                              dg1.mrz.dateOfBirth, context),
                                          style: TextStyle(fontSize: 16))),
                                ]),
                                Row(children: <Widget>[
                                  Expanded(
                                      child: Text('Sex:',
                                          style: TextStyle(fontSize: 16))),
                                  Expanded(
                                    child: Text(
                                        dg1.mrz.sex.isEmpty
                                            ? '/'
                                            : dg1.mrz.sex == 'M'
                                                ? 'Male'
                                                : 'Female',
                                        style: TextStyle(fontSize: 16)),
                                  )
                                ]),
                                Row(children: <Widget>[
                                  Expanded(
                                      child: Text('Nationality:',
                                          style: TextStyle(fontSize: 16))),
                                  Expanded(
                                      child: Text(_nationality,
                                          style: TextStyle(fontSize: 16))),
                                ]),
                                Row(children: <Widget>[
                                  Text('Additional Data:',
                                      style: TextStyle(fontSize: 16)),
                                  Spacer(),
                                  Text(dg1.mrz.optionalData,
                                      style: TextStyle(fontSize: 16)),
                                  Spacer()
                                ]),
                              ])))),
              Spacer(flex: 60),
              Wrap(
                  direction: Axis.horizontal,
                  runSpacing: 10,
                  spacing: 10,
                  children: <Widget>[...actions])
            ])));
  }
}
