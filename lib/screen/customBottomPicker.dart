import 'package:dmrtd/src/utils.dart';
import 'package:eosio_passid_mobile_app/utils/structure.dart';
import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/screen/requestType.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:flutter/foundation.dart';
import "dart:io" show Platform;

class BottomPickerElement{
  String key;
  String name;
  bool isSelected;

  BottomPickerElement({@required this.name, @required this.isSelected, this.key  = null})
  {
    if(this.key == null)
      this.key = this.name;
  }
}


class BottomPickerStructure{
  bool isValid = false;
  String title;
  String message;
  List<BottomPickerElement> elements = List();


  void importStorageNodeList(List<StorageNode> nodes, [StorageNode selectedNode = null, String title = null, String message = null]){
    this.isValid = true;
    this.title = (title == null ? "" : title);
    this.message = (message == null ? "" : message);

    for(var item in nodes)
      this.elements.add(BottomPickerElement(name: item.name,
          isSelected: (selectedNode != null && item.name == selectedNode.name?true:false)));
  }

  void importStorageRequestList(Map<RequestType, dynamic> authenticatorActions, [RequestType selectedRequest = null, String title = null, String message = null]){
    this.isValid = true;
    this.title = (title == null ? "" : title);
    this.message = (message == null ? "" : message);

    authenticatorActions.forEach((key, value) { 
      this.elements.add(BottomPickerElement(name: value["NAME"],
          isSelected: selectedRequest == key? true : false,
          key: StringUtil.getWithoutTypeName(key) )
      );
    });
  }

  void importstorageServerList(List<StorageServer> nodes, [StorageServer selectedServer = null]){
    this.isValid = true;
    this.title = (title == null ? "" : title);
    this.message = (message == null ? "" : message);

    for(var item in nodes)
      this.elements.add(BottomPickerElement(name: item.name,
          isSelected: (selectedServer != null && item.name == selectedServer.name?true:false)));
  }



  void importActionTypesList(Map actions, [String selectedAction = null, String title = null, String message = null]){
    this.isValid = true;
    this.title = (title == null ? "" : title);
    this.message = (message == null ? "" : message);

    for (var item in actions.keys) {
          this.elements.add(BottomPickerElement(name: actions[item]["NAME"],
              isSelected: (selectedAction != null && item == selectedAction?true:false),
          key: StringUtil.getWithoutTypeName(item)));
      //print("Key : $k, value : ${numMap[k]}");
    }
  }
}

class CustomBottomPickerState{ //extends State<CustomBottomPicker> {
  BottomPickerStructure structure;

  CustomBottomPickerState({@required this.structure});


  BottomPickerElement showIosBottomPicker(BuildContext context, Function function)
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

  BottomPickerElement showAndroidBottomPicker(BuildContext context, Function function)
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
   BottomPickerElement showPicker(BuildContext context, Function function) {
    if (Platform.isAndroid)
      {
        this.showAndroidBottomPicker(context, function);
      }
    else if (Platform.isIOS)
      {
        return this.showIosBottomPicker(context, function);
      }
    else
      return null;
  }
}