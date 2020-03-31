import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:flutter/foundation.dart';
import "dart:io" show Platform;

class ModalBottomSheetNFCelement{
  String name;
  bool isSelected;

  ModalBottomSheetNFCelement({@required this.name, @required this.isSelected});
}


class CustomModalBottomSheetNFC{
  ModalBottomSheetNFCelement structure;

  CustomModalBottomSheetNFC({@required this.structure});


  ModalBottomSheetNFCelement showAndroidBottomPicker(BuildContext context, Function function)
  {/*
    final items = <Widget>[
      for (var item in this.structure.elements)
        ListTile(
            leading: (item.isSelected?Icon(Icons.radio_button_checked):Icon(Icons.radio_button_unchecked)),
            title: Text(item.name),
            onTap: () {
              function(item);
              Navigator.pop(context);
            }
        )
    ];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext _) {
        return Container(
          child: Wrap(
            children: items,
          ),
        );
      },
      isScrollControlled: true,
    );*/
  }


  //@override
  ModalBottomSheetNFCelement showBottomSHeetNFC(BuildContext context, Function function) {
    if (Platform.isAndroid)
      this.showAndroidBottomPicker(context, function);
    else if (Platform.isIOS)
    {
      //it shows automatic by system - on nfc call
    }
    else
      return null;
  }
}