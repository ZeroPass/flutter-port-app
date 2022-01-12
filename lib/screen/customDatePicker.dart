import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_port_mobile_app/screen/theme.dart';
//import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:date_format/date_format.dart';
import "dart:io" show Platform;
import "package:intl/intl.dart";
import 'nfc/uie/uiutils.dart';


class CustomDatePicker extends StatefulWidget {
  late String text;
  late DateTime firstDate;
  late DateTime lastDate;
  late DateTime initialDate;
  late DateTime onShowValue;
  late TextEditingController textEditingController ;
  late Function? callbackOnDatePicked;
  late Function? callbackOnUpdate;


  CustomDatePicker({required this.text, required this.firstDate, required this.lastDate,
    this.callbackOnDatePicked, this.callbackOnUpdate, TextEditingController? textEditingController, DateTime? initialDate,
    DateTime? onShowValue})
  {
    this.textEditingController = textEditingController ??  TextEditingController();
    this.initialDate = initialDate ?? DateTime.now();
    this.onShowValue = onShowValue ?? DateTime.now();
  }

  @override
  _CustomDatePicker createState() => _CustomDatePicker();

  void changeText(String text){
    this.textEditingController.text = text;
  }

  static String formatDate(DateTime dt)
  {
    return DateFormat('dd MMM yyyy', 'en_US').format(dt);
    //return DateFormat.yMMMd().format(dt);
  }

  //static DateTime parseDate(String strDate)
  //{
  //  return DateFormat.yMMMd().parse(strDate);
  //}

  static DateTime parseDateFormated(String strDate)
  {
    return DateFormat('dd MMM yyyy', 'en_US').parse(strDate);
    //return DateFormat('MMM d, yyyy', 'en_US').parse();
  }

  static bool isDateStringFormatedValid(String strDate)
  {
    try {
      parseDateFormated(strDate);
      return true;
    }
    catch(e){
      return false;
    }
  }

  static bool isDateFormatedValid(String strDate)
  {
    try {
      parseDateFormated(strDate);
      return true;
    }
    catch(e){
      return false;
    }
  }
}

class _CustomDatePicker extends State<CustomDatePicker> {
  _CustomDatePicker();


  //not in use anymore
  Widget showAndroidDatePicker(BuildContext context){
    if (widget.onShowValue != null)
      widget.textEditingController.text = CustomDatePicker.formatDate(widget.onShowValue);

    return TextFormField(
      showCursor: false,
      controller: widget.textEditingController,
      decoration: InputDecoration(labelText: widget.text),
      onChanged: (String value) {
        if(widget.callbackOnUpdate != null)
          widget.callbackOnUpdate!(value);
      },
      onTap: () async {
        FocusScope.of(context).unfocus();
        if(widget.textEditingController.text.isNotEmpty && CustomDatePicker.isDateStringFormatedValid(widget.textEditingController.text))
          widget.initialDate =  CustomDatePicker.parseDateFormated(widget.textEditingController.text); // Set init date to previously selected date
        else
          widget.initialDate = new DateTime(DateTime.now().year, 1, 1);//January 1st, current year

        if(widget.initialDate.isBefore(widget.firstDate)) {
          widget.initialDate = widget.firstDate;
        }
        else if(widget.initialDate.isAfter(widget.lastDate)) {
          widget.initialDate = widget.lastDate;
        }

        DateTime? pickedDate = await pickDate(
            context,
            widget.firstDate,
            widget.initialDate ,
            widget.lastDate);

        if (pickedDate != null) {
          widget.textEditingController.text = CustomDatePicker.formatDate(pickedDate);
        }

        //return to function on call
        if (widget.callbackOnDatePicked != null && pickedDate != null) {
          widget.callbackOnDatePicked!(pickedDate);
        }
    });
  }

  Future<dynamic> _pickDate(BuildContext context, {required DateTime initDate, required DateTime firstDate, required DateTime lastDate}) async {
    // iOS style date picker
    DateTime date = initDate;
    return showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: Theme.of(context).dialogBackgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            PlatformDialogAction(
              child: PlatformText('Done'),
              onPressed: () => Navigator.pop(context, date)
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: date,
                minimumDate: firstDate,
                maximumDate: lastDate,
                onDateTimeChanged: (d) => date = d
            )),
            const SizedBox(height: 20)
      ])),
      useRootNavigator: true
    );
  }

  void _updateInitDateTime() {
    if(widget.textEditingController.text.isNotEmpty && CustomDatePicker.isDateStringFormatedValid(widget.textEditingController.text)) {
      widget.initialDate = CustomDatePicker.parseDateFormated(widget.textEditingController.text); // Set init date to previously selected date
    }

    // Clamp init date to first/last date
    if(widget.initialDate.isBefore(widget.firstDate)) {
      widget.initialDate = widget.firstDate;
    }
    else if(widget.initialDate.isAfter(widget.lastDate)) {
      widget.initialDate = widget.lastDate;
    }
  }

  Widget showAndroidDatePickerHoloTheme(BuildContext context){
    if (widget.onShowValue != null) {
      //widget.textEditingController.text = CustomDatePicker.formatDate(widget.onShowValue);
      widget.textEditingController.addListener(() {
        if (widget.text == '')
        widget.textEditingController.text = CustomDatePicker.formatDate(widget.onShowValue);
      });
    }

    return TextFormField(
        //readOnly: true,
        showCursor: false,
        //autofocus: true,
        toolbarOptions: ToolbarOptions(copy: true, paste: true, cut: true, selectAll: true),
        textInputAction: TextInputAction.none,
        controller: widget.textEditingController,
        decoration: InputDecoration(labelText: widget.text),
        onChanged: (String value) {
          if(widget.callbackOnUpdate != null)
            widget.callbackOnUpdate!(value);

        },
        onTap: () async {
          //FocusScope.of(context).requestFocus(new FocusNode());
          FocusScope.of(context).unfocus();
          _updateInitDateTime();
          var pickedDate = await DatePicker.showSimpleDatePicker(
            context,
            backgroundColor: DateTimePickerTheme.Default.backgroundColor.withOpacity(1.0),
            initialDate: widget.initialDate,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            dateFormat: "dd-MMM-yyyy",
            locale: DateTimePickerLocale.en_us,
            looping: true,
          );

          if (pickedDate != null) {
            widget.textEditingController.text = CustomDatePicker.formatDate(pickedDate);
          }

          //return to function on call
          if (widget.callbackOnDatePicked != null && pickedDate != null)
            widget.callbackOnDatePicked!(pickedDate);
        });
  }

  Widget showIosDatePicker(BuildContext context){
    return TextFormField(
      controller: widget.textEditingController,
      decoration: InputDecoration(labelText: widget.text),
      onTap: () async {
        FocusScope.of(context).requestFocus(new FocusNode());
        
        _updateInitDateTime();
        final pickedDate = await _pickDate(context, initDate: widget.initialDate, firstDate: widget.firstDate, lastDate: widget.lastDate);
        if (pickedDate != null) {
          widget.textEditingController.text = CustomDatePicker.formatDate(pickedDate);
        }

        //return to function on call
        if (widget.callbackOnDatePicked != null && pickedDate != null)
          widget.callbackOnDatePicked!(pickedDate);

    });
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid)
    {
      //return this.showIosDatePicker(context);
      return this.showAndroidDatePickerHoloTheme(context);
    }
    else if (Platform.isIOS)
    {
      return this.showIosDatePicker(context);
    }
    else
      throw Exception("CustomDatePicker.build unknown platform detected.");
  }
}