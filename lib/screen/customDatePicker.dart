import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:date_format/date_format.dart';
import "dart:io" show Platform;
import "package:intl/intl.dart";


class CustomDatePicker extends StatefulWidget {
  String text;
  DateTime firstDate;
  DateTime lastDate;
  DateTime initialDate;
  TextEditingController textEditingController ;
  Function callbackOnDatePicked;

  CustomDatePicker([@required this.text, @required this.firstDate, @required this.lastDate, this.callbackOnDatePicked, this.textEditingController = null, this.initialDate = null,])
  {
    if (this.initialDate == null)
      this.initialDate = new DateTime(DateTime.now().year, 1, 1);//January 1st, current year
    //textEditingController = new TextEditingController();
  }

  @override
  _CustomDatePicker createState() => _CustomDatePicker();

  static String customizeDate(DateTime dt)
  {
    return DateFormat.yMMMd().format(dt);
  }
}

class _CustomDatePicker extends State<CustomDatePicker> {
  _CustomDatePicker();


  Widget showAndroidDatePicker(BuildContext context){
      return TextFormField(
              controller: widget.textEditingController,
              decoration: InputDecoration(labelText: widget.text),
              onTap: () async{

                FocusScope.of(context).requestFocus(new FocusNode());
                var datePicked = await DatePicker.showSimpleDatePicker(
                  context,
                  initialDate: widget.initialDate,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  dateFormat: "dd-MMMM-yyyy",
                  locale: DateTimePickerLocale.en_us,
                );
                //var t = DateFormat.yMMMd().
                if (datePicked != null)
                  widget.textEditingController.text = CustomDatePicker.customizeDate(datePicked);

                //return to function on call
                if (widget.callbackOnDatePicked != null && datePicked != null)
                  widget.callbackOnDatePicked(datePicked);
              });
  }

  Widget showIosDatePicker(BuildContext context){
    //TODO:implement this function
    /*DatePickerWidget({
      DateTime minDateTime,
      DateTime maxDateTime,
      DateTime initialDateTime,
      String dateFormat: DATETIME_PICKER_DATE_FORMAT,
      DateTimePickerLocale locale: DATETIME_PICKER_LOCALE_DEFAULT,
      DateTimePickerTheme pickerTheme: DatePickerTheme.Default,
      DateVoidCallback onCancel,
      DateValueCallback onChange,
      DateValueCallback onConfirm,
    })*/
    print("show ios picer");
    return TextFormField(
        controller: widget.textEditingController,
        decoration: InputDecoration(labelText: widget.text),
        onTap: () async{
          DatePickerWidget(
            initialDate: widget.initialDate,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            dateFormat: "dd-MMMM-yyyy",
            onConfirm: (DateTime dt, List<int> values){
              print(dt);
              print(values);
            }
            );
            }
    );

  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid)
    {
      //return this.showIosDatePicker(context);
      return this.showAndroidDatePicker(context);
    }
    else if (Platform.isIOS)
    {
      return this.showIosDatePicker(context);
    }
    else
      return null;
  }
}