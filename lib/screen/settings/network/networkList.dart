import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:eosio_passid_mobile_app/constants/constants.dart';
import 'package:eosio_passid_mobile_app/screen/settings/network/updateNetwork.dart';
import 'package:eosio_passid_mobile_app/screen/settings/custom/customCardSettingsButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/screen/slideToSideRoute.dart';

class SettingsNetworkList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var storage = Storage();
    //List<NodeServer> storageNodes = storage.nodeSet.nodes[NetworkType.MAINNET].servers;
    List<Network> networks = storage.nodeSet.networks.values.toList();
    return PlatformScaffold(
        material: (_, __) =>
            MaterialScaffoldData(resizeToAvoidBottomInset: false),
        cupertino: (_, __) =>
            CupertinoPageScaffoldData(resizeToAvoidBottomInset: false),
        appBar: PlatformAppBar(
          title: Text("Networks"),
        ),
        body: ListView.builder(
            itemCount: networks.length,
            itemBuilder: (BuildContext context, int idx) {
              return CustomCardSettingsButton(label: networks[idx].name,
                  onPressed: (){
                    final page = SettingsUpdateNetwork(networkType: networks[idx].networkType);
                    Navigator.of(context).push(SlideToSideRoute(page));
                  });
            }));
  }
}