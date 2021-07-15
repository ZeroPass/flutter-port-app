 import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:eosio_port_mobile_app/constants/constants.dart';
import 'package:eosio_port_mobile_app/screen/settings/network/updateNetwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_port_mobile_app/utils/storage.dart';
import 'package:eosio_port_mobile_app/screen/slideToSideRoute.dart';

class SettingsNetwork extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var storage = Storage();

    if ( storage.nodeSet.nodes[NetworkType.MAINNET] == null ||
          storage.nodeSet.nodes[NetworkType.MAINNET]!.servers != null)
      throw Exception("SettingsNetwork.build; server list is null");

    List<Server> storageNodes = storage.nodeSet.nodes[NetworkType.MAINNET]!.servers;
    return PlatformScaffold(
        material: (_, __) =>
            MaterialScaffoldData(resizeToAvoidBottomInset: false),
        cupertino: (_, __) =>
            CupertinoPageScaffoldData(resizeToAvoidBottomInset: false),
        appBar: PlatformAppBar(
          title: Text("Select network"),
        ),
        body: ListView.builder(
            itemCount: storageNodes.length,
            itemBuilder: (BuildContext context, int idx) {
              return PlatformWidget(
                  cupertino: (_, __) => CupertinoListTile(
                      leading: Icon(Icons.cloud),
                      title: Text(storageNodes[idx].toString()),
                      //subtitle: Text(storageNodes[idx].host),
                      onTap: () {
                        //open 'update network' panel
                        //final page = SettingsNetworkUpdate(
                        //    storage: storage, storageNode: storageNodes[idx]);
                        //Navigator.of(context).push(SlideToSideRoute(page));
                      }),
                  material: (_, __) => ListTile(
                      leading: Icon(Icons.cloud),
                      title: Text(storageNodes[idx].toString()),
                      //subtitle: Text(storageNodes[idx].host),
                      onTap: () {
                        //open 'update network' panel
                        //final page = SettingsNetworkUpdate(
                        //    storage: storage, storageNode: storageNodes[idx]);
                        //Navigator.of(context).push(SlideToSideRoute(page));
                      }));
            }));
  }
}