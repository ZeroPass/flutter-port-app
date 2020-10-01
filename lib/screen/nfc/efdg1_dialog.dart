//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'package:dart_countries_states/country_provider.dart';
import 'package:dart_countries_states/models/alpha2_codes.dart';
import 'package:dart_countries_states/models/alpha3_code.dart';
import 'package:dart_countries_states/models/country.dart';
import 'package:eosio_passid_mobile_app/screen/customCardShowHide.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:eosio_passid_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:dmrtd/dmrtd.dart';
import 'package:eosio_passid_mobile_app/screen/customCard.dart';
import 'package:eosio_passid_mobile_app/screen/requestType.dart';

import '../../utils/structure.dart';
import 'uie/uiutils.dart';

// Dialog displays MRZ data stored in file EF.DG1
/*Future<T> showEfDG1Dialog<T>(BuildContext context, EfDG1 dg1,
    {String message, List<Widget> actions}) {
  return EfDG1Dialog(context, dg1, message: message, actions: actions).show();
}
*/
class EfDG1Dialog extends StatefulWidget {
  final EfDG1 dg1;
  final BuildContext context;
  final String message;
  final List<Widget> actions;
  final _countryProvider = CountryProvider();
  var _issuingCountry;
  var _nationality;
  StateSetter _sheetSetter;
  final String rawData;

  EfDG1Dialog(
      {@required this.context,
      @required this.dg1,
      @required this.message,
      @required this.actions,
      @required this.rawData
      });

  @override
  _EfDG1Dialog createState() => _EfDG1Dialog();
}

class _EfDG1Dialog extends State<EfDG1Dialog> {
  @override
  void initState() {
    super.initState();
    _formatCountryCode(widget.dg1.mrz.country).then((c) {
      if (widget._sheetSetter != null) {
        widget._sheetSetter(() => widget._issuingCountry = c);
      } else {
        widget._issuingCountry = c;
      }
    });

    _formatCountryCode(widget.dg1.mrz.nationality).then((c) {
      if (widget._sheetSetter != null) {
        widget._sheetSetter(() => widget._nationality = c);
      } else {
        widget._nationality = c;
      }
    });
  }

  /*Future<T> show<T>() {
    return _showBottomSheet();
  }*/

  String _formatDate(DateTime date, BuildContext ctx) {
    final locale = getLocaleOf(ctx);
    return formatDate(date, locale: locale);
  }

  Future<String> _formatCountryCode(String code) async {
    try {
      Country c;
      if (code.length == 2) {
        c = await widget._countryProvider
            .getCountryByCode2(code2: Alpha2Code.valueOf(code));
      } else {
        c = await widget._countryProvider
            .getCountryByCode3(code3: Alpha3Code.valueOf(code));
      }
      return c.name;
    } catch (_) {
      return code;
    }
  }

  Future<T> _showBottomSheet<T>() {
    if (widget._sheetSetter != null) {
      return null;
    }

    return showModalBottomSheet(
        context: context,
        isDismissible: false,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            widget._sheetSetter = setState;
            build(context); //widget
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    Storage storage = Storage();
    StepDataAttestation stepDataAttestation = storage.getStorageData(2);
    return Container(
        height: MediaQuery.of(context).size.height * 1.2,
        child: Padding(
            padding: EdgeInsets.all(0.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 0),
                  if (widget.message != null)
                    Text(
                      widget.message,
                    ),
                  const SizedBox(height: 14),
                  CustomCard("Personal Data", [
                    CardItem('Name', widget.dg1.mrz.firstName),
                    CardItem('Last Name', widget.dg1.mrz.lastName),
                    CardItem("Date of Birth",
                        _formatDate(widget.dg1.mrz.dateOfBirth, context)),
                    CardItem(
                        "Sex",
                        widget.dg1.mrz.sex.isEmpty
                            ? '/'
                            : widget.dg1.mrz.sex == 'M' ? 'Male' : 'Female'),
                    CardItem("Nationality:", widget.dg1.mrz.nationality),
                    CardItem("Additional Data:", widget.dg1.mrz.optionalData)
                  ]),
                  const SizedBox(height: 18),
                  CustomCard("Passport Data", [
                    CardItem("Passport type", widget.dg1.mrz.documentCode),
                    CardItem("Passport no.", widget.dg1.mrz.documentNumber),
                    CardItem("Date of Expiry",
                        _formatDate(widget.dg1.mrz.dateOfExpiry, context)),
                    CardItem("Issuing Country:", widget.dg1.mrz.country)
                  ]),
                  const SizedBox(height: 18),
                  CustomCard("Authn Data", [
                    for (var item
                        in AuthenticatorActions[stepDataAttestation.requestType]
                            ["DATA_IN_REVIEW"])
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
