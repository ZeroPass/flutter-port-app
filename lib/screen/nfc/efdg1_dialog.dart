//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'package:dart_countries_states/country_provider.dart';
import 'package:dart_countries_states/models/alpha2_codes.dart';
import 'package:dart_countries_states/models/alpha3_code.dart';
import 'package:dart_countries_states/models/country.dart';
import 'package:port_mobile_app/screen/customCardShowHide.dart';
import 'package:port_mobile_app/screen/main/stepper/stepAttestation/stepAttestation.dart';
import 'package:port_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:port_mobile_app/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:dmrtd/dmrtd.dart';
import 'package:port_mobile_app/screen/customCard.dart';
import 'package:port_mobile_app/screen/requestType.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:port_mobile_app/screen/flushbar.dart';
import 'package:flutter/services.dart';

import '../../utils/structure.dart';
import 'uie/uiutils.dart';

class EfDG1Dialog extends StatefulWidget {
  final EfDG1 dg1;
  final BuildContext context;
  final String message;
  final List<Widget> actions;
  final _countryProvider = CountryProvider();
  var issuingCountry;
  var nationality;
  late StateSetter? sheetSetter;
  final String rawData;

  EfDG1Dialog(
      {required this.context,
      required this.dg1,
        this.message = '',
      required this.actions,
      required this.rawData,
      this.sheetSetter
      });

  @override
  _EfDG1Dialog createState() => _EfDG1Dialog();
}

class _EfDG1Dialog extends State<EfDG1Dialog> {
  @override
  void initState() {
    super.initState();
    _formatCountryCode(widget.dg1.mrz.country).then((c) {
      if (widget.sheetSetter != null)
        widget.sheetSetter!(() => widget.issuingCountry = c);
      else
        widget.issuingCountry = c;
    });

    _formatCountryCode(widget.dg1.mrz.nationality).then((c) {
      if (widget.sheetSetter != null)
        widget.sheetSetter!(() => widget.nationality = c);
      else
        widget.nationality = c;
    });
  }

  String _formatDate(DateTime date, BuildContext ctx) {
    final locale = getLocaleOf(ctx);
    return formatDate(date, locale: locale);
  }

  Future<String> _formatCountryCode(String code) async {
    try {
      Country c;
      if (code.length == 2) {
        c = (await widget._countryProvider
            .getCountryByCode2(code2: Alpha2Code.valueOf(code)))!;
      } else {
        c = (await widget._countryProvider
            .getCountryByCode3(code3: Alpha3Code.valueOf(code)))!;
      }
      return c.name ?? code;
    } catch (_) {
      return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    Storage storage = Storage();
    StepDataAttestation stepDataAttestation = storage.getStorageData(2) as StepDataAttestation;
    return Container(
        height: MediaQuery.of(context).size.height * 1.3,
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
                        widget.dg1.mrz.gender.isEmpty
                            ? '/'
                            : widget.dg1.mrz.gender == 'M' ? 'Male' : 'Female'),
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
                  /*const SizedBox(height: 18),
                  CustomCardShowHide("Raw Data", this.widget.rawData,
                      actions: [
                        PlatformDialogAction(
                          child: Text('Copy'),
                          onPressed: () {
                            showFlushbar(context, "Clipboard", "Item was copied to clipboard.", Icons.info);
                            Clipboard.setData(ClipboardData(text: this.widget.rawData));
                          },
                        )
                      ]),*/
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
