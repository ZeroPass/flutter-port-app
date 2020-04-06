//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'package:dart_countries_states/country_provider.dart';
import 'package:dart_countries_states/models/alpha2_codes.dart';
import 'package:dart_countries_states/models/alpha3_code.dart';
import 'package:dart_countries_states/models/country.dart';
import 'package:flutter/material.dart';
import 'package:dmrtd/dmrtd.dart';

import '../utils.dart';
import 'uiutils.dart';

// Screen displays MRZ data stored in file EF.DG1
class EfDG1View extends StatefulWidget {
  final EfDG1 dg1;
  EfDG1View(this.dg1, {Key key}) : super(key: key);
  _EfDG1ViewState createState() => _EfDG1ViewState(dg1);
}

class _EfDG1ViewState extends State<EfDG1View> {
  final EfDG1 dg1;
  final _countryProvider = CountryProvider();
  String _issuingCountry = '';
  String _nationality = '';

  @override
  void initState() {
    super.initState();
    _formatCountryCode(dg1.mrz.country).then((c) {
      setState(() => _issuingCountry = c);
    });
    _formatCountryCode(dg1.mrz.nationality).then((c) {
      setState(() => _nationality = c);
    });
  }

  _EfDG1ViewState(this.dg1);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
            elevation: 1.0,
            title: Text('Data to be sent'),
            backgroundColor: Theme.of(context).cardColor,
            leading: Container(),
            actions: <Widget>[
              IconButton(
                iconSize: 40,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                ),
                onPressed: () => Navigator.maybePop(context),
              )
            ]),
        body: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
            ),
            child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                    child: Card(
                        child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Passport Data',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  _formatDate(dg1.mrz.dateOfExpiry, context),
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
                              fontWeight: FontWeight.bold, fontSize: 18),
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
                                child: Text(capitalize(dg1.mrz.lastName),
                                    style: TextStyle(fontSize: 16))),
                          ],
                        ),
                        Row(children: <Widget>[
                          Expanded(
                              child: Text('Date of Birth:',
                                  style: TextStyle(fontSize: 16))),
                          Expanded(
                              child: Text(
                                  _formatDate(dg1.mrz.dateOfBirth, context),
                                  style: TextStyle(fontSize: 16))),
                        ]),
                        Row(children: <Widget>[
                          Expanded(
                              child:
                                  Text('Sex:', style: TextStyle(fontSize: 16))),
                          Expanded(
                            child: Text(
                                dg1.mrz.sex.isEmpty
                                    ? '/'
                                    : dg1.mrz.sex == 'M' ? 'Male' : 'Female',
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
                      ]),
                ))))));
  }
}
