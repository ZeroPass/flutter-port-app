import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/constants/constants.dart';
import 'package:eosio_passid_mobile_app/utils/structure.dart';
import 'package:card_settings/card_settings.dart';
import 'package:eosio_passid_mobile_app/screen/alert.dart';
import 'package:eosio_passid_mobile_app/screen/settings/custom/customCardSettingsButton.dart';
import 'package:eosio_passid_mobile_app/screen/settings/custom/CustomCardSettingsSection.dart';
import 'package:eosio_passid_mobile_app/screen/settings/custom/customCardSettings.dart';
import 'package:eosio_passid_mobile_app/screen/settings/network/server/updateServer.dart';
import 'package:logging/logging.dart';
import 'package:eosio_passid_mobile_app/screen/slideToSideRoute.dart';

class SettingsUpdateNetwork extends StatelessWidget {
  final _log = Logger('Settings.SettingsUpdateNetwork');
  NetworkType networkType;

  //active network; got by type
  Network network;
  //to check if any field has been updated
  Network networkToUpdate;


  SettingsUpdateNetwork({@required this.networkType})
  {
    Storage storage = Storage();
    this.network = storage.nodeSet.networks[this.networkType];
    this.networkToUpdate = new Network.clone(network);
    //init validation fields
    //this.storageNode.initValidation(); TODO
  }

  void onButtonPressedDelete() {}

  void onButtonPressedSave(BuildContext context)
  {
    Storage storage = Storage();

    //copy values to storage if there is any change
    if (!this.network.compare(this.networkToUpdate)) {
      this.network.clone(this.networkToUpdate); // = new StorageNode.clone(this.currentUpdatedValues);
      storage.nodeSet.networks[this.networkType].clone(this.networkToUpdate);
      storage.save();
    }
    showAlert(
        context: context,
        title: Text("The data have been saved successfully"),
        closeOnBackPressed: true);
  }

  Future<bool> onWillPop(BuildContext context) {
    if (!this.network.compare(this.networkToUpdate)) {
      showAlert(
          context: context,
          title: Text("The data has been changed."),
          actions: [
            PlatformDialogAction(
                child: PlatformText('Back'),
                onPressed: () {
                  Navigator.pop(context);
                }),
            PlatformDialogAction(
                child: PlatformText('Save and go',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  this.network = new Network.clone(this.networkToUpdate);
                  Navigator.pop(context);
                })
          ]);
      return new Future.value(false);
    } else
      return new Future.value(true);
  }


  dynamic returnList(){
    Storage storage = Storage();
    var t = ListView.builder(
        shrinkWrap: true,
        itemCount: storage.nodeSet.nodes[this.networkType].servers.length,
        itemBuilder: (BuildContext context, int idx) {
          return CustomCardSettingsButton(label: storage.nodeSet.nodes[this.networkType].servers[idx].toString(),
              onPressed: (){
                final page = SettingsUpdateServer(networkType: this.networkType, server: storage.nodeSet.nodes[this.networkType].servers[idx] );
                Navigator.of(context).push(SlideToSideRoute(page));
              });
        });
    return t;
  }


  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    Storage storage = Storage();
    returnList();
    return PlatformScaffold(
        material: (_,__) => MaterialScaffoldData(resizeToAvoidBottomInset: false),
        cupertino: (_,__) => CupertinoPageScaffoldData(resizeToAvoidBottomInset: false),
        appBar: PlatformAppBar(
          //automaticallyImplyLeading: true,
          title: Text("Update network", style: TextStyle(color: Colors.white)),
          trailingActions: <Widget>[
            PlatformIconButton(
                cupertino: (_,__) => CupertinoIconButtonData(
                  icon: Icon(
                    CupertinoIcons.delete,
                    color: Colors.white,
                    size: 30
                  ), 
                  padding: EdgeInsets.only(right: 20),
                ),
                materialIcon: Icon(Icons.delete_outline, size: 35.0),
                material: (_,__) => MaterialIconButtonData(tooltip: 'Delete'),
                onPressed: () {
                  /*final page = Settings();
                Navigator.of(context).push(SlideToSideRoute(page));
              */
                }),
            PlatformIconButton(
                cupertino: (_,__) => CupertinoIconButtonData(
                  icon: Icon( // Save icon
                    const IconData(0xf41F, fontPackage: CupertinoIcons.iconFontPackage, fontFamily: CupertinoIcons.iconFont),
                    color: Colors.white,
                    size: 35
                  ), 
                  padding: EdgeInsets.all(0),
                ),
                androidIcon: Icon(Icons.save, size: 35.0),
                material: (_, __) => MaterialIconButtonData(tooltip: 'Save'),
                onPressed: () {
                  onButtonPressedSave(context);
                  /*final page = Settings();
                Navigator.of(context).push(SlideToSideRoute(page));
              */
                })
          ],
        ),
        body: WillPopScope(
          onWillPop: () => onWillPop(context),
          child: Form(
            key: _formKey,
            child: Column(children: <Widget>[
              CustomCardSettings(children: <CardSettingsSection>[
                CustomCardSettingsSection(children: <CardSettingsWidget>[
              CardSettingsText(
                  label: 'Name',
                  contentAlign: TextAlign.right,
                  initialValue: this.networkToUpdate.name,
                  autovalidate: true,
                  enabled: this.networkToUpdate.networkType == NetworkType.CUSTOM ? true : false,
                  validator: (value) {
                    _log.finer("Change name: $value");
                    if (this.networkToUpdate.networkType != NetworkType.CUSTOM) {
                      _log.finest("Cannot change the name; network type is not custom.");
                      return "You cannot change the name, because it is predefined.";
                    }
                    if (value == null || value.isEmpty) {
                      _log.finest("Change name; value is null.");
                      this.networkToUpdate.setValidationError("name", "Field 'Name' is empty.");
                      return 'Title is required.';
                    }
                    this.networkToUpdate.setValidationCorrect("name");
                    this.networkToUpdate.name = value;
                    return null;
                  },
              ),
              CardSettingsText(
                  label: 'Chain ID',
                  contentAlign: TextAlign.right,
                  initialValue: this.networkToUpdate.chainID,
                  enabled: this.networkToUpdate.networkType == NetworkType.CUSTOM ? true : false,
                  autovalidate: true,
                  validator: (value) {
                    _log.finer("Chain ID: $value");
                    this.networkToUpdate.chainID = "kva";
                    if (this.networkToUpdate.networkType != NetworkType.CUSTOM) {
                      _log.finest("Cannot change 'Chain ID'; network type is not custom.");
                      return "You cannot change 'Chain ID', because it is predefined.";
                    }
                    if (value == null || value.isEmpty) {
                      _log.finest("Change 'Chain ID''; value is null.");
                      this.networkToUpdate.setValidationError("chainID", "Field 'Chain ID' is empty.");
                      return '"Chain ID" is required.';
                    }
                    this.networkToUpdate.setValidationCorrect("chainID");
                    this.networkToUpdate.chainID = value;
                    return null;
                  },
                  onSaved: (value) {
                    if (this.networkToUpdate.networkType == NetworkType.CUSTOM)
                      this.networkToUpdate.chainID = value;
                  }),

            ],
          ),
        ]
        ),
              Text("Nodes"),
              Container(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: storage.nodeSet.nodes[this.networkType].servers.length,
                      itemBuilder: (BuildContext context, int idx) {
                        return CustomCardSettingsButton(label: storage.nodeSet.nodes[this.networkType].servers[idx].toString(),
                        onPressed: (){
                          final page = SettingsUpdateServer(networkType: this.networkType, server: storage.nodeSet.nodes[this.networkType].servers[idx] );
                          Navigator.of(context).push(SlideToSideRoute(page));
                        });
                  })
              )
            ])
          ),
        ));
  }
}