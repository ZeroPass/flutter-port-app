import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_port_mobile_app/utils/storage.dart';
import 'package:eosio_port_mobile_app/constants/constants.dart';
import 'package:card_settings/card_settings.dart';
import 'package:eosio_port_mobile_app/screen/alert.dart';
import 'package:eosio_port_mobile_app/screen/settings/custom/CustomCardSettingsButtonDelete.dart';
import 'package:logging/logging.dart';

class SettingsUpdateCloud extends StatelessWidget {
  final _log = Logger('Settings.SettingsUpdateCloud');

  late NetworkTypeServer networkTypeServer;
  late Server server;
  //to check if any field has been updated
  late Server serverToUpdate;

  SettingsUpdateCloud({required this.networkTypeServer})
  {
    if (this.networkTypeServer != NetworkTypeServer.MAIN_SERVER)
      throw Exception("Not correct network type server");

    Storage storage = Storage();
    if (storage.cloudSet.servers[NetworkTypeServer.MAIN_SERVER] == null ||
        storage.cloudSet.servers[NetworkTypeServer.MAIN_SERVER]!.servers == null ||
        storage.cloudSet.servers[NetworkTypeServer.MAIN_SERVER]!.servers.length == 0)
      throw Exception("Not server defined");

    this.server = storage.cloudSet.servers[NetworkTypeServer.MAIN_SERVER]!.servers.first;
    this.serverToUpdate = new Server.clone(server);
    //init validation fields
    this.server.initValidation();
  }

  void onButtonPressedDelete({required BuildContext context}) async {
    _log.fine("Button 'delete' clicked");
    bool? answer = await showAlert<bool>(
        context: context,
        title: Text("Are you sure you want to delete na item?"),
        actions: <PlatformDialogAction>[
          PlatformDialogAction(
              child: PlatformText('No'),
              onPressed: () => Navigator.pop(context, false)
          ),
          PlatformDialogAction(
              child: PlatformText('Yes'),
              onPressed: () => Navigator.pop(context, true)
          ),
        ],
        closeOnBackPressed: true);
    if (answer!= null && answer){
      Storage storage = Storage();
      if (storage.cloudSet.servers[NetworkTypeServer.MAIN_SERVER] == null ||
          storage.cloudSet.servers[NetworkTypeServer.MAIN_SERVER]!.servers == null ||
          storage.cloudSet.servers[NetworkTypeServer.MAIN_SERVER]!.servers.length == 0)
        throw Exception("Not server defined");

      for (var element in storage.cloudSet.servers[this.networkTypeServer]!.servers){
        if (this.server.compare(element)){
          _log.finest("Element found in database.");
          element.clone(serverToUpdate);
          storage.cloudSet.servers[this.networkTypeServer]!.delete(element);
          storage.save();
          Navigator.pop(context);
          break;
        }
      }
    }
  }

  void onButtonPressedSave({required BuildContext context, bool showNotification = true})
  {
    _log.fine("Save clicked");
    Storage storage = Storage();

    //copy values to storage if there is any change
    if (!this.server.compare(this.serverToUpdate)) {
      if (storage.cloudSet.servers[NetworkTypeServer.MAIN_SERVER] == null ||
          storage.cloudSet.servers[NetworkTypeServer.MAIN_SERVER]!.servers == null ||
          storage.cloudSet.servers[NetworkTypeServer.MAIN_SERVER]!.servers.length == 0)
        throw Exception("Not server defined");

      for (var element in storage.cloudSet.servers[this.networkTypeServer]!.servers){
        if (this.server.compare(element)){
          _log.finest("Element found in database. Clone the new data to this element.");
          element.clone(serverToUpdate);
          this.server.clone(this.serverToUpdate);
          storage.save(callback: (successfull){
            if (successfull && showNotification && context != null)
              showAlert(
                  context: context,
                  title: Text("The data have been saved successfully"),
                  closeOnBackPressed: true);
          });
          break;
        }
      }
    }
    else
      _log.finer("No data has been changed since last save/open.");
  }

  Future<bool> onWillPop(BuildContext context) async {
    if (!this.server.compare(this.serverToUpdate)) {
      bool? answer = await showAlert<bool>(
          context: context,
          title: Text("The data has been changed."),
          actions: [
            PlatformDialogAction(
                child: PlatformText('Back'),
                onPressed: () {
                  Navigator.pop(context, false);
                  //return false;
                }),
            PlatformDialogAction(
                child: PlatformText('Save and go',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  onButtonPressedSave(context: context, showNotification: false);
                  Navigator.pop(context, true);
                  //return true;
                })
          ]);
      return new Future.value(answer ?? false);
    } else
      return new Future.value(true);
  }

  String validator(String value){
    _log.finer("URL: $value");
    if (value == null || value.isEmpty) {
      _log.finest("URL; value is null.");
      this.serverToUpdate.setValidationError("name", "Field 'url' is empty.");
      return 'URL is required.';
    }
    if (RegExp(r'[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&=]*)').hasMatch(value) == false){
      _log.finest("URL; regular expression does not match.");
      this.serverToUpdate.setValidationError("name", "Field 'URL' not match regular expression.");
      return 'Not valid URL address.';
    }
    return '';
  }

  String onChanged(String value){
    _log.finer("URL: $value");
    if (value == null || value.isEmpty) {
      _log.finest("URL; value is null.");
      this.serverToUpdate.setValidationError("name", "Field 'url' is empty.");
      return 'URL is required.';
    }

    try {
      this.serverToUpdate.host = Uri.parse(value);
    }
    catch(e){
      if (value.length > 5)
        return "Not valid URL addresss";
    }
    return '';
  }

  String initialValue(){/**/
    return this.serverToUpdate.toString();
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    return PlatformScaffold(
        material: (_,__) => MaterialScaffoldData(resizeToAvoidBottomInset: false),
        cupertino: (_,__) => CupertinoPageScaffoldData(resizeToAvoidBottomInset: false),
        appBar: PlatformAppBar(
          //automaticallyImplyLeading: true,
          title: Text("Update server", style: TextStyle(color: Colors.white)),
          trailingActions: <Widget>[
            PlatformIconButton(
                cupertino: (_,__) => CupertinoIconButtonData(
                  icon: Icon( // Save icon
                      const IconData(0xf41F, fontPackage: CupertinoIcons.iconFontPackage, fontFamily: CupertinoIcons.iconFont),
                      color: Colors.white,
                      size: 35
                  ),
                  padding: EdgeInsets.all(0),
                ),
                materialIcon: Icon(Icons.save, size: 35.0),
                material: (_, __) => MaterialIconButtonData(tooltip: 'Save'),
                onPressed: () {
                  onButtonPressedSave(showNotification: true, context: context);
                })
          ],
        ),
        body: WillPopScope(
          onWillPop: () => onWillPop(context),
          key: _formKey,
          child: Form(
              child: Column(children: [
                CardSettings(
                    children: <CardSettingsSection>[
                      CardSettingsSection(
                        children: <CardSettingsWidget>[
                          new CardSettingsText(
                            label: 'URL',
                            maxLength: 100,
                            contentAlign: TextAlign.right,
                            initialValue: initialValue(),
                            //autovalidate: true,
                            //enabled: this.networkType == NetworkType.CUSTOM ? true : false,

                            //validator: (value) {
                            //  return validator(value);
                            //},
                            onChanged: (value){
                              onChanged(value);
                            },
                          ),
                        ],
                      ),
                    ]
                ),
                CustomCardSettingsButtonDelete(onPressed: (){
                  onButtonPressedDelete(context: context);
                })
              ])
          ),
        ));
  }
}