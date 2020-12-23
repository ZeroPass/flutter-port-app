import 'package:eosio_passid_mobile_app/screen/settings/network/updateNetwork.dart';
import 'package:eosio_passid_mobile_app/screen/settings/custom/customCardSettingsButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/screen/slideToSideRoute.dart';
import 'package:logging/logging.dart';

class SettingsNetworkList extends StatelessWidget {
  final _log = Logger('Settings.SettingsNetworkList');

  @override
  Widget build(BuildContext context) {
    var storage = Storage();
    List<Network> networks = List<Network>();
    _log.fine("Merge two 'maps', show only elements which are in both maps.");
    storage.nodeSet.networks.forEach((key, value){
      if (storage.nodeSet.nodes.containsKey(key)){
        _log.finest("NetworkType is in both dict: $key");
        networks.add(value);
      }
    });

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