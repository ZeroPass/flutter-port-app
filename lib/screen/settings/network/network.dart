import 'package:eosio_passid_mobile_app/screen/settings/network/updateNetwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/screen/slideToSideRoute.dart';

class SettingsNetwork extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var storage = Storage();
    List<StorageNode> storageNodes = storage.storageNodes();
    final items = <Widget>[
    //for (StorageNode item in storage.storageNodes())
    for(var i = 0;i<storageNodes.length;i++)
      ListTile(
          leading: Icon(Icons.cloud),
          title: Text(storageNodes[i].name),
          subtitle: Text(storageNodes[i].networkType.toString()),
          onTap: () {
            //open 'update network' panel
            final page = SettingsNetworkUpdate(storage: storage, storageNode: storageNodes[i]);
            Navigator.of(context).push(SlideToSideRoute(page));
          }
        )
      ];


    return PlatformScaffold(
        android: (_) => MaterialScaffoldData(resizeToAvoidBottomInset: false),
        ios: (_) => CupertinoPageScaffoldData(resizeToAvoidBottomInset: false),
        appBar: PlatformAppBar(
          title: Text("Select network"),
        ),
        body:ListView(
          children:ListTile.divideTiles(
          context: context,
          tiles: items
        ).toList()
        )
    );
  }
}



/*var storage = Storage();

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
    );*/