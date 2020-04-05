import 'package:flutter/material.dart';
//import 'package:shared_preferences_settings/shared_preferences_settings.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/settings/settings.dart';
import 'package:eosio_passid_mobile_app/utils/structure.dart';
import 'package:card_settings/card_settings.dart';

import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import 'package:bloc/bloc.dart';



class SettingsNetworkUpdate extends StatelessWidget {
  StorageNode storageNode;

  SettingsNetworkUpdate({@required StorageNode this.storageNode});


  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    List<String> chainsKeys = [];
    List<String> chainsValues = [];
    for (var item in settings['chain_id'].entries) {
      chainsKeys.add(StringUtil.getWithoutTypeName(item.key));
      chainsValues.add(item.key.toString());
    }
    return Scaffold(
        appBar: AppBar(
          title: Text("Select network"),
        ),
        body:
        Form(
          key: _formKey,
          child: CardSettings(
            padding: 0,
            children: <Widget>[
              CardSettingsText(
                label: 'Name',
                contentAlign: TextAlign.right,
                initialValue: storageNode.name,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Title is required.';
                  return "";
                },
                onSaved: (value) => storageNode.name = value,
              ),

              CardSettingsText(
                label: 'Host',
                contentAlign: TextAlign.right,
                initialValue: storageNode.host,
                validator: (value) {
                  if (!(value.startsWith('http:') || value.startsWith('https:'))) return 'Must be a valid website.';
                  return "";
                },
                onSaved: (value) => storageNode.host = value,
              ),
              CardSettingsInt(
                label: 'Port',
                contentAlign: TextAlign.right,
                initialValue: storageNode.port,
                validator: (value) {
                  if (value < 0) return 'Port need to be unsigned.';
                  return "";
                },
                onSaved: (value) => storageNode.port = value,
              ),
              CardSettingsSwitch(
                label: 'Encrypted connection',
                contentAlign: TextAlign.right,
                initialValue: storageNode.isEncryptedEndpoint,
                onSaved: (value) => storageNode.isEncryptedEndpoint = value,
              ),
              CardSettingsListPicker(
                label: 'Network type',
                contentAlign: TextAlign.right,
                initialValue: storageNode.networkType.toString(),
                options: chainsKeys,
                values: chainsValues,
                onChanged: (value) {
                  print(value);
                  storageNode.networkType = EnumUtil.fromStringEnum(
                      NetworkType.values, StringUtil.getWithoutTypeName(value));
                }
              ),
              CardSettingsText(
                label: 'Chain ID',
                contentAlign: TextAlign.right,
                initialValue: storageNode.chainID,
                enabled: false,// storageNode.networkType == NetworkType.CUSTOM? false: true,
                visible: true,
                validator: (value) {
                  print("kva je");
                  if (storageNode.networkType != NetworkType.CUSTOM)
                    return "You cannot change chain id. Network type is not selected as custom.";
                  return "";
                },
                onSaved: (value) {
                  print("kva je 1");
                  if (storageNode.networkType == NetworkType.CUSTOM)
                    storageNode.chainID = value;
                  }
              ),
              //for (var item in settings['chain_id'].entries)
              //            item.key.toString(): item.key.toString().replaceAll("NetworkType.", "")
            ],
          ),
        ),


    );
  }
}

/*
class ChainIDfield extends StatefulWidget {
  String title;
  bool enabled;

  ChainIDfield([@required this.title, @required this.enabled]);

  @override
  _ChainIDfieldState createState() => _ChainIDfieldState();
}

class _ChainIDfieldState extends State<ChainIDfield> {
  _ChainIDfieldState();

  @override
  Widget build(BuildContext context) {
    return TextFieldModalSettingsTile(
        settingKey: 'storage-node-chainId',
        title: 'Chai1n ID',
        defaultValue: widget.title,
        visibleByDefault: true,
        keyboardType: TextInputType.text,

        //enabledIfKey: 'storage-node-network-type',
        //visibleByDefault: false,
      );
    }
}


class SettingsNetworkUpdate extends StatelessWidget {
  StorageNode storageNode;
  StatefulWidget chainIdField;

  SettingsNetworkUpdate({@required StorageNode this.storageNode}){
    chainIdField = ChainIDfield("kaj", true);
  }

  @override
  Widget build(BuildContext context) {
      return Form(
        key: _formKey,
        child: CardSettings(
          children: <Widget>[
            CardSettingsHeader(label: 'Favorite Book'),
            CardSettingsText(
              label: 'Title',
              initialValue: title,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Title is required.';
              },
              onSaved: (value) => title = value,
            ),
            CardSettingsText(
              label: 'URL',
              initialValue: url,
              validator: (value) {
                if (!value.startsWith('http:')) return 'Must be a valid website.';
              },
              onSaved: (value) => url = value,
            ),
          ],
        ),
      ),
      );

    return SettingsScreen(title: "Update Network", children: <Widget>[
      TextFieldModalSettingsTile(
      settingKey: 'storage-node-name',
        title: 'Name',
        defaultValue: storageNode.name,
        cancelCaption: 'Cancel',
        okCaption: 'Save',
        keyboardType: TextInputType.text
      ),
      Settings().onStringChanged(
        settingKey: 'storage-node-name',
        childBuilder: (BuildContext context, String value){
          storageNode.name = value;
          return Text("");
        },
      ),


      TextFieldModalSettingsTile(
        settingKey: 'storage-node-host',
        title: 'Host',
        defaultValue: storageNode.host,
        cancelCaption: 'Cancel',
        okCaption: 'Save',
        keyboardType: TextInputType.url,
      ),
      Settings().onStringChanged(
        settingKey: 'storage-node-host',
        childBuilder: (BuildContext context, String value){
          storageNode.host = value;
          return Text("");
        },
      ),

      TextFieldModalSettingsTile(
        settingKey: 'storage-node-port',
        title: 'Port',
        defaultValue: storageNode.port.toString(),
        cancelCaption: 'Cancel',
        okCaption: 'Save',
        keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
      ),
      Settings().onIntChanged(
        settingKey: 'storage-node-port',
        childBuilder: (BuildContext context, int value){
          storageNode.port = value;
          return Text("");
        },
      ),


      SwitchSettingsTile(
        settingKey: 'storage-node-encrypted',
        title: 'Encrypted connection',
        defaultValue: storageNode.isEncryptedEndpoint?true:false,
      ),

      Settings().onBoolChanged(
      settingKey: 'storage-node-encrypted',
      defaultValue: false,
      childBuilder: (BuildContext context, bool value){
        storageNode.isEncryptedEndpoint = value;
        return Text('');
        },
      ),


      RadioPickerSettingsTile(
        settingKey: 'storage-node-network-type',
        title: 'Select network type',
        defaultKey: StringUtil.getWithoutTypeName(storageNode.networkType),
        values: {
          for (var item in settings['chain_id'].entries)
            item.key.toString(): item.key.toString().replaceAll("NetworkType.", ""),
        },
      ),
      Settings().onStringChanged(
        settingKey: 'storage-node-network-type',
        defaultValue: 'Empty',
        childBuilder: (BuildContext context, String value){
          NetworkType parsedNT = EnumUtil.fromStringEnum(NetworkType.values, StringUtil.getWithoutTypeName(value));
          String chainId = settings['chain_id'][parsedNT];
          if (chainId != null){
            storageNode.networkType = parsedNT;
            storageNode.chainID = chainId;
            print(chainId);
            //print("kaj je to"+chainId.);
            print("kaj je to"+chainId.toString());
            Settings().pingString("storage-node-chainId", chainId);
            chainIdField = ChainIDfield("kaj", true);

          }
          //else
          //  Settings().pingString("storage-node-chainId", " ");

          return Text("");
        },
      ),

      chainIdField,
      /*Settings().onStringChanged(
        settingKey: 'storage-node-chainId',
        childBuilder: (BuildContext context, String value){
          return Text("");
        },
      )*/

    ]
    );
  }
}*/