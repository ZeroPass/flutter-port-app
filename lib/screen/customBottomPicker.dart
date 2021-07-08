import 'package:dmrtd/src/utils.dart';
import 'package:eosio_passid_mobile_app/utils/structure.dart';
import 'package:eosio_passid_mobile_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/screen/requestType.dart';
import 'package:flutter/cupertino.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:flutter/foundation.dart';
import "dart:io" show Platform;

class BottomPickerElement{
  late String key;
  late String name;
  late bool isSelected;

  BottomPickerElement({required this.name, required this.isSelected, String? key})
  {
      this.key = key ?? this.name;
  }
}

class BottomPickerStructure{
  bool isValid = false;
  late String title;
  late String message;
  late List<BottomPickerElement> elements;


  void importNetworkList(NetworkNodeSet networkNodeSet, NetworkType selectedNetwork,
  {String? title = "", String? message = ""}){
    this.isValid = true;

    if (networkNodeSet.networks.isEmpty)
      throw Exception("No networks in database");

    this.elements = List.empty(growable: true);
    networkNodeSet.networks.forEach((key, value) =>
      this.elements.add(BottomPickerElement(name: Storage().nodeSet.networkTypeIsPredefined(key) ?  Storage().nodeSet.networkTypeToString(key) :  StringUtil.getWithoutTypeName(key),
          key: StringUtil.getWithoutTypeName(key),
          isSelected: key == selectedNetwork)));
  }

  void importStorageRequestList(Map<RequestType, dynamic> authenticatorActions,
      [RequestType? selectedRequest, String? title, String? message]){
    this.isValid = true;
    this.title = title ?? "";
    this.message = message ?? "";

    this.elements = List.empty(growable: true);
    for (var item in authenticatorActions.keys){
      this.elements.add(BottomPickerElement(name: authenticatorActions[item]["NAME"],
          isSelected: selectedRequest == item? true : false,
          key: StringUtil.getWithoutTypeName(item)));
    }
  }

  void importstorageServerList(List<ServerCloud> nodes, {ServerCloud? selectedServer, String? title, String? message}){
    this.isValid = true;
    this.title = title ?? "";
    this.message = message ?? "";

    for(var item in nodes)
      this.elements.add(BottomPickerElement(name: item.name,
          isSelected: (selectedServer != null && item.name == selectedServer.name?true:false)));
  }



  void importActionTypesList(Map actions, {String? selectedAction, String? title, String? message}){
    this.isValid = true;
    this.title = title ?? "";
    this.message = message ?? "";

    for (var item in actions.keys) {
          this.elements.add(BottomPickerElement(name: actions[item]["NAME"],
              isSelected: (selectedAction != null && item == selectedAction?true:false),
          key: StringUtil.getWithoutTypeName(item)));
    }
  }
}

class CustomBottomPickerState{ //extends State<CustomBottomPicker> {
  BottomPickerStructure structure;

  CustomBottomPickerState({required this.structure});


  void showIosBottomPicker(BuildContext context, Function function)
  {
    final items = <Widget>[
      for (var item in this.structure.elements)
      CupertinoActionSheetAction(
        child: Text(item.name),
        onPressed: () {
          {
            function(item);
            Navigator.pop(context);
          }
        },
      )
    ];

    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
            //title: Text(this.structure.title),
            //message: Text(this.structure.message),
            actions: items,
            cancelButton: CupertinoActionSheetAction(
              child: const Text('Cancel'),
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context, 'Cancel');
              },
            )
        )
    ).whenComplete(() {

    });
  }

  void showAndroidBottomPicker(BuildContext context, Function function)
  {
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
    );
  }


  //@override
   void showPicker(BuildContext context, Function function) {
    if (Platform.isAndroid)
        this.showAndroidBottomPicker(context, function);
    else if (Platform.isIOS)
        this.showIosBottomPicker(context, function);
  }
}