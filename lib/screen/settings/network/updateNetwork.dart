import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/settings/settings.dart';
import 'package:eosio_passid_mobile_app/utils/structure.dart';
import 'package:card_settings/card_settings.dart';
import 'package:eosio_passid_mobile_app/screen/alert.dart';

/*
class SettingsNetworkUpdate extends StatefulWidget {
  Storage storage;
  StorageNode storageNode;
  //to check if any field has been updated
  StorageNode currentUpdatedValues;

  SettingsNetworkUpdate({@required Storage this.storage, @required StorageNode this.storageNode});

  @override
  State<StatefulWidget> createState() {
    return new _SettingsNetworkUpdate();
  }
}

class _SettingsNetworkUpdate extends State<SettingsNetworkUpdate> {

 */

class SettingsNetworkUpdate extends StatelessWidget {
  Storage storage;
  StorageNode storageNode;


  //to check if any field has been updated
  StorageNode currentUpdatedValues;

  SettingsNetworkUpdate({@required Storage this.storage, @required StorageNode this.storageNode})
  {
    this.currentUpdatedValues = new StorageNode.clone(this.storageNode);
    //init validation fields
    this.storageNode.initValidation();
  }

  void onButtonPressedDelete() {}

  void onButtonPressedSave(BuildContext context)
  {
    //copy values to storage if there is any change
    if (!this.storageNode.compare(this.currentUpdatedValues))
      this.storageNode.clone(this.currentUpdatedValues);// = new StorageNode.clone(this.currentUpdatedValues);
    storage.save();
    showAlert(
        context: context,
        title: Text("The data have been saved successfully"),
        closeOnBackPressed: true);
  }

  Future<bool> onWillPop(BuildContext context) {
    if (!this.storageNode.compare(this.currentUpdatedValues)) {
      showAlert(
          context: context,
          title: Text("The data have been saved successfully"),
          actions: [
            PlatformDialogAction(
                child: PlatformText('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                }),
            PlatformDialogAction(
                child: PlatformText('Save and go',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  this.storageNode =
                      new StorageNode.clone(this.currentUpdatedValues);
                  Navigator.pop(context);
                })
          ]);
      return new Future.value(false);
    } else
      return new Future.value(true);
  }



  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    List<String> chainsKeys = [];
    List<String> chainsValues = [];
    for (var item in settings['chain_id'].entries) {
      chainsKeys.add(StringUtil.getWithoutTypeName(item.key));
      chainsValues.add(item.key.toString());
    }
    return PlatformScaffold(
        android: (_) => MaterialScaffoldData(resizeToAvoidBottomInset: false),
        ios: (_) => CupertinoPageScaffoldData(resizeToAvoidBottomInset: false),
        appBar: PlatformAppBar(
          //automaticallyImplyLeading: true,
          title: Text("Edit", style: TextStyle(color: Colors.white)),
          trailingActions: <Widget>[
            PlatformIconButton(
                iosIcon: Icon(Icons.delete_outline, color: Colors.white),
                androidIcon: Icon(Icons.delete_outline, size: 35.0),
                android: (_) => MaterialIconButtonData(tooltip: 'Delete'),
                onPressed: () {
                  /*final page = Settings();
                Navigator.of(context).push(SlideToSideRoute(page));
              */
                }),
            PlatformIconButton(
                iosIcon: Icon(Icons.save, color: Colors.white),
                androidIcon: Icon(Icons.save, size: 35.0),
                android: (_) => MaterialIconButtonData(tooltip: 'Save'),
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
            child: CardSettingsSection(
              children: [
                CardSettingsText(
                  label: 'Name',
                  contentAlign: TextAlign.right,
                  initialValue: storageNode.name,
                  autovalidate: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      this.storageNode.setValidationError("name", "Field 'Title' is empty.");
                      return 'Title is required.';
                    }
                    this.storageNode.setValidationCorrect("name");
                    this.currentUpdatedValues.name = value;
                    return "";
                  }
                ),
                CardSettingsText(
                  label: 'Host',
                  contentAlign: TextAlign.right,
                  initialValue: storageNode.host,
                  autovalidate: true,
                  validator: (value) {
                    if (!(value.startsWith('http:') || value.startsWith('https:'))) {
                      this.storageNode.setValidationError("host", "Field 'Host' is not valid.");
                      return "Host must start with 'http(s)://'";
                    }
                    this.storageNode.setValidationCorrect("host");
                    this.currentUpdatedValues.host = value;
                    return "";
                  }
                ),
                CardSettingsInt(
                  label: 'Port',
                  contentAlign: TextAlign.right,
                  initialValue: storageNode.port,
                  autovalidate: true,
                  validator: (value) {
                    if (value == null)
                    {
                      this.storageNode.setValidationError("port", "Field 'post' is empty.");
                      return 'There must be a value.';
                    }
                    if (value < 0)
                    {
                      this.storageNode.setValidationError("port", "Field 'post' is negative.");
                      return 'Port need to be unsigned.';
                    }
                    this.storageNode.setValidationCorrect("port");
                    this.currentUpdatedValues.port = value;
                    return "";
                  }
                ),
                CardSettingsSwitch(
                  label: 'Encrypted connection',
                  contentAlign: TextAlign.right,
                  initialValue: storageNode.isEncryptedEndpoint,
                  onSaved: (value) =>
                      this.currentUpdatedValues.isEncryptedEndpoint = value,
                ),
                CardSettingsListPicker(
                    label: 'Network type',
                    contentAlign: TextAlign.right,
                    initialValue: storageNode.networkType.toString(),
                    options: chainsKeys,
                    values: chainsValues,
                    onChanged:  (value) async {
                      //setState(() { this.storageNode.networkType = NetworkType.CUSTOM; });
                      this.currentUpdatedValues.networkType =
                          EnumUtil.fromStringEnum(NetworkType.values,
                              StringUtil.getWithoutTypeName(value));
                      var r = this.currentUpdatedValues.networkType == NetworkType.CUSTOM;
                      print (r);
                      var t = 9;
                    }),
                CardSettingsText(
                    label: 'Chain ID',
                    contentAlign: TextAlign.right,
                    initialValue: storageNode.chainID,
                    enabled: this.currentUpdatedValues.networkType == NetworkType.CUSTOM? true : false,
                    visible: this.currentUpdatedValues.networkType == NetworkType.CUSTOM? true : false,
                    autovalidate: true,
                    validator: (value) {
                      if (this.currentUpdatedValues.networkType !=
                          NetworkType.CUSTOM)
                        return "You cannot change chain id. Network type is not selected as custom.";
                      return "";
                    },
                    onSaved: (value) {
                      if (this.currentUpdatedValues.networkType ==
                          NetworkType.CUSTOM)
                        this.currentUpdatedValues.chainID = value;
                    }),
              ],
            ),
          ),
        ));
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
