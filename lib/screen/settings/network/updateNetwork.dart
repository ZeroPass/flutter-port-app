import 'package:flutter/material.dart';
import 'package:shared_preferences_settings/shared_preferences_settings.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';

class SettingsNetworkUpdate extends StatelessWidget {
  StorageNode storageNode;

  SettingsNetworkUpdate({@required StorageNode this.storageNode});

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(title: "Update Network", children: <Widget>[
      TextFieldModalSettingsTile(
      settingKey: 'storage-node-name',
        title: 'Name',
        defaultValue: storageNode.name,
        cancelCaption: 'Cancel',
        okCaption: 'Save',
        keyboardType: TextInputType.text,
      ),
      TextFieldModalSettingsTile(
        settingKey: 'storage-node-host',
        title: 'Host',
        defaultValue: storageNode.host,
        cancelCaption: 'Cancel',
        okCaption: 'Save',
        keyboardType: TextInputType.url,
      ),
      SwitchSettingsTile(
        settingKey: 'storage-node-encrypted',
        title: 'Encrypted connection',
        /*onChange: (value) {
              debugPrint('USB Debugging: $value');
            },*/
      )
    ]);
  }
}
