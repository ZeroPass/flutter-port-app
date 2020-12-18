import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/constants/constants.dart';
import 'package:eosio_passid_mobile_app/utils/structure.dart';
import 'package:card_settings/card_settings.dart';
import 'package:eosio_passid_mobile_app/screen/alert.dart';
import 'package:eosio_passid_mobile_app/screen/settings/custom/CustomCardSettingsButtonDelete.dart';
import 'package:logging/logging.dart';

class SettingsUpdateServer extends StatelessWidget {
  final _log = Logger('Settings.SettingsUpdateServer');

  NetworkType networkType;
  Server server;
  //to check if any field has been updated
  Server serverToUpdate;

  SettingsUpdateServer({@required this.networkType, @required this.server})
  {
    this.serverToUpdate = new Server.clone(server);
    //init validation fields
    this.server.initValidation();
  }

  void onButtonPressedDelete({@required BuildContext context}) {
    var kva = showAlert(
        context: context,
        title: Text("The data have been saved successfully"),
        closeOnBackPressed: true);
    var y = 9;

  }

  void onButtonPressedSave({@required BuildContext context, bool showNotification = true})
  {
    _log.fine("Save clicked");
    Storage storage = Storage();

    //copy values to storage if there is any change
    if (!this.server.compare(this.serverToUpdate)) {
      _log.finer("No data has been changed since last save/open.");
        for (var element in storage.nodeSet.nodes[this.networkType].servers){
        if (this.server.compare(element)){
          _log.finest("Element found in database. Clone the new data to this element.");
          element.clone(serverToUpdate);
          this.server.clone(this.serverToUpdate);
          storage.save();
          break;
        }
      }
    }
    if (showNotification && context != null)
      showAlert(
          context: context,
          title: Text("The data have been saved successfully"),
          closeOnBackPressed: true);
  }

  Future<bool> onWillPop(BuildContext context) {
    if (!this.server.compare(this.serverToUpdate)) {
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
                  onButtonPressedSave(context: context);
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
    Storage storage = Storage();

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
                  onButtonPressedSave(showNotification: true, context: context);
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
              child: Column(children: [
                CardSettings(
                    children: <CardSettingsSection>[
                      CardSettingsSection(
                        children: <CardSettingsWidget>[
                          CardSettingsText(
                            label: 'URL',
                            contentAlign: TextAlign.right,
                            initialValue: this.serverToUpdate.toString(),
                            autovalidate: true,
                            //enabled: this.networkType == NetworkType.CUSTOM ? true : false,
                            validator: (value) {
                              _log.finer("URL: $value");
                              /*if (this.networkType != NetworkType.CUSTOM) {
                                _log.finest("Cannot change URL field network type is not custom.");
                                return "You cannot change URL field, because it is predefined.";
                              }*/
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


                              this.serverToUpdate.setValidationCorrect("name");
                              this.serverToUpdate.host = value;
                              return null;
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