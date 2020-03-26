import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import 'package:bloc/bloc.dart';
import "dart:io" show Platform;

class CustomDatePicker extends StatefulWidget {
  List<String> titles;

  CustomDatePicker([@required this.titles]);

  @override
  _CustomDatePicker createState() => _CustomDatePicker();
}

class _CustomDatePicker extends State<CustomDatePicker> {
  _CustomDatePicker();

  Future<Null> _selectDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    final locale = Localizations.localeOf(context);
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101),
        locale: locale);
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Widget showAndroidBottomPicker(BuildContext context){
    DateTime selectedDate = DateTime.now();
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("${selectedDate.toLocal()}".split(' ')[0]),
            SizedBox(height: 20.0,),
            RaisedButton(
              onPressed: () => _selectDate(context),
              child: Text('Select date'),
            ),
          ],
        ),
      );
  }

  Widget showIosBottomPicker(BuildContext context){

  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid)
    {
      return this.showAndroidBottomPicker(context);
    }
    else if (Platform.isIOS)
    {
      return this.showIosBottomPicker(context);
    }
    else
      return null;
  }
}