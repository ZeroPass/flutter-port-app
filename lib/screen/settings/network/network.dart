import 'package:eosio_passid_mobile_app/screen/settings/network/updateNetwork.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences_settings/shared_preferences_settings.dart';
import 'package:eosio_passid_mobile_app/screen/settings/network/network.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';

class SettingsNetwork extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    var storage = Storage();

    final items = <Widget>[
      for (StorageNode item in storage.storageNodes())
        SimpleSettingsTile(
          icon: Icon(Icons.cloud),
          title: item.name,
          subtitle: item.networkType.toString(),
          screen: SettingsNetworkUpdate(storageNode: item),
        )
    ];

    return SettingsScreen(
        title: "Network",
        children: items
    );
  }
}
