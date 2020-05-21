import 'package:flutter/material.dart';
//import 'package:shared_preferences_settings/shared_preferences_settings.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';
import 'package:eosio_passid_mobile_app/screen/settings/network/network.dart';
import 'package:card_settings/card_settings.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Settings extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        android: (_) => MaterialScaffoldData(resizeToAvoidBottomPadding: false),
        ios: (_) => CupertinoPageScaffoldData(resizeToAvoidBottomInset: false),
        appBar: PlatformAppBar(
        title: Text("Settings"),
      ),
        body:SettingsScreen()
      );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Form(
      key: _formKey,
      child: CardSettings(
        padding: 0,
        children: <Widget>[
          CardSettingsHeader(label: 'Network'),
          ListTile(
              leading: Icon(Icons.cloud),
              title: Text("Node management"),
              onTap: () {
                //open 'update network' panel
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsNetwork()));
              }
          ),
          ListTile(
              leading: Icon(Icons.cloud),
              title: Text("Server management"),
              onTap: () {
                //function(item);
                // Navigator.pop(context);
              }
          ),
          CardSettingsHeader(label: 'About'),
          ListTile(
              leading: Icon(Icons.info),
              title: Text("PassID"),
              subtitle: Text(AndroidThemeST().getValues().themeValues["APP_DATA"]["COMPANY_NAME"] +
                  ' ('+ AndroidThemeST().getValues().themeValues["APP_DATA"]["YEAR_LAST_UPDATE"].toString() +  '), version:' +
                  AndroidThemeST().getValues().themeValues["APP_DATA"]["VERSION"]),
              onTap: () {
                //function(item);
                // Navigator.pop(context);
              }
          ),


        ],
      ),
    )
    );

  }
}



/*class CustomSettings extends StatefulWidget {

  CustomSettings();

  @override
  _CustomSettingsState createState() => _CustomSettingsState();
}

class _CustomSettingsState extends State<CustomSettings> {

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(
      title: "Application Settings",
      children: [],
    );
  }
}*/
/*
class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return SettingsScreen(
        title: "Settings",
        children:[
          SettingsTileGroup(
            title: 'Network',
            children:[
              SimpleSettingsTile(
                    icon: Icon(Icons.cloud),
                    title: 'Node',
                    subtitle: 'EOS node management',
                    screen: SettingsNetwork(),
                  )
                ]),




          SimpleSettingsTile(
            title: 'PassID',
            subtitle: AndroidThemeST().getValues().themeValues["APP_DATA"]["COMPANY_NAME"] +
                      ' ('+
                      AndroidThemeST().getValues().themeValues["APP_DATA"]["YEAR_LAST_UPDATE"].toString() +
                      '), version:' +
                      AndroidThemeST().getValues().themeValues["APP_DATA"]["VERSION"],
            ),

        ]
    );*/

    //working comment
    /*return SettingsScreen(
      title: "Application Settings",
      children:[
        SimpleSettingsTile(
      title: 'More Settings',
      subtitle: 'General App Settings',
      screen: SettingsScreen(
        title: "App Settings",
        children: <Widget>[
          CheckboxSettingsTile(
            icon: Icon(Icons.adb),
            settingKey: 'key-is-developer',
            title: 'Developer Mode',
            /*onChange: (bool value) {
              debugPrint('Developer Mode ${value ? 'on' : 'off'}');
            },*/
          ),
          SwitchSettingsTile(
            icon: Icon(Icons.usb),
            settingKey: 'key-is-usb-debugging',
            title: 'USB Debugging',
            /*onChange: (value) {
              debugPrint('USB Debugging: $value');
            },*/
          ),
        ],
      ),
    )
    ]
    );
    */

    /*return SettingsScreen(
        title: "Application Settings",
        children:[
          CheckboxSettingsTile(
            settingKey: 'key-of-your-setting',
            title: 'This is a simple Checkbox',
          ),

          RadioSettingsTile(
          settingKey: 'key-of-your-setting',
          title: 'Select one option',
          values: {
          'a': 'Option A',
          'b': 'Option B',
          'c': 'Option C',
          'd': 'Option D',
          },
          ),

          SwitchSettingsTile(
            settingKey: 'wifi_status',
            title: 'Wi-Fi',
            subtitle: 'Connected.',
            subtitleIfOff: 'To see available networks, turn on Wi-Fi.',
            screen: SettingsToggleScreen(
                settingKey: 'wifi_status',
                subtitle: 'Connected',
                subtitleIfOff: 'To see available networks, turn on Wi-Fi.',
                children:[
                  SettingsContainer(
                    children:[
                    Text('Put some widgets or tiles here.'),
                  ],
                ),
                  /*SettingsContainer(
                  children:[
                    Text('You are offline.'),
                    Text('Put some widgets or tiles here.'),
                ],
          ),*/
        ],
    ),
    ),

        RadioPickerSettingsTile(
        settingKey: 'key-of-your-setting',
        title: 'Choose one in the modal dialog',
        values: {
        'a': 'Option A',
        'b': 'Option B',
        'c': 'Option C',
        'd': 'Option D',
        },
        defaultKey: 'b',
        )

        ]
    );*/

    /*return Container(
      child: SettingsScreen(
        title: "Application Settings",
        children: [
          SettingsTileGroup(
            title: 'Single Choice Settings',
            children: <Widget>[
              SwitchSettingsTile(
                settingKey: 'key-wifi',
                title: 'Wi-Fi',
                subtitle: 'Enabled',`
                subtitleIfOff: 'Disabled',
                icon: Icon(Icons.wifi),
                onChange: (value) {
                  debugPrint('key-wifi: $value');
                },
              ),
              CheckboxSettingsTile(
                settingKey: 'key-blue-tooth',
                title: 'Bluetooth',
                subtitle: 'Enabled',
                subtitleIfOff: 'Disabled',
                icon: Icon(Icons.bluetooth),
                onChange: (value) {
                  debugPrint('key-blue-tooth: $value');
                },
              ),
              SwitchSettingsTile(
                icon: Icon(Icons.developer_mode),
                settingKey: 'key-switch-dev-mode',
                title: 'Developer Settings',
                onChange: (value) {
                  debugPrint('key-switch-dev-mod: $value');
                },
                childrenIfEnabled: <Widget>[
                  CheckboxSettingsTile(
                    icon: Icon(Icons.adb),
                    settingKey: 'key-is-developer',
                    title: 'Developer Mode',
                    onChange: (value) {
                      debugPrint('key-is-developer: $value');
                    },
                  ),
                  SwitchSettingsTile(
                    icon: Icon(Icons.usb),
                    settingKey: 'key-is-usb-debugging',
                    title: 'USB Debugging',
                    onChange: (value) {
                      debugPrint('key-is-usb-debugging: $value');
                    },
                  ),
                  SimpleSettingsTile(
                    title: 'Root Settings',
                    subtitle: 'These settings is not accessible',
                    enabled: false,
                  )
                ],
              ),
              SimpleSettingsTile(
                title: 'More Settings',
                subtitle: 'General App Settings',
                screen: SettingsScreen(
                  title: "App Settings",
                  children: <Widget>[
                    CheckboxSettingsTile(
                      icon: Icon(Icons.adb),
                      settingKey: 'key-is-developer',
                      title: 'Developer Mode',
                      onChange: (bool value) {
                        debugPrint('Developer Mode ${value ? 'on' : 'off'}');
                      },
                    ),
                    SwitchSettingsTile(
                      icon: Icon(Icons.usb),
                      settingKey: 'key-is-usb-debugging',
                      title: 'USB Debugging',
                      onChange: (value) {
                        debugPrint('USB Debugging: $value');
                      },
                    ),
                  ],
                ),
              ),
              TextInputSettingsTile(
                title: 'User Name',
                settingKey: 'key-user-name',
                initialValue: 'admin',
                validator: (String username) {
                  if (username != null && username.length > 3) {
                    return null;
                  }
                  return "User Name can't be smaller than 4 letters";
                },
                borderColor: Colors.blueAccent,
                errorColor: Colors.deepOrangeAccent,
              ),
              TextInputSettingsTile(
                title: 'password',
                settingKey: 'key-user-password',
                obscureText: true,
                validator: (String password) {
                  if (password != null && password.length > 6) {
                    return null;
                  }
                  return "Password can't be smaller than 7 letters";
                },
                borderColor: Colors.blueAccent,
                errorColor: Colors.deepOrangeAccent,
              ),
              ModalSettingsTile(
                title: 'Quick setting dialog',
                subtitle: 'Settings on a dialog',
                children: <Widget>[
                  CheckboxSettingsTile(
                    settingKey: 'key-day-light-savings',
                    title: 'Daylight Time Saving',
                    enabledLabel: 'Enabled',
                    disabledLabel: 'Disabled',
                    leading: Icon(Icons.timelapse),
                    onChange: (value) {
                      debugPrint('key-day-light-saving: $value');
                    },
                  ),
                  SwitchSettingsTile(
                    settingKey: 'key-dark-mode',
                    title: 'Dark Mode',
                    enabledLabel: 'Enabled',
                    disabledLabel: 'Disabled',
                    leading: Icon(Icons.palette),
                    onChange: (value) {
                      debugPrint('jey-dark-mode: $value');
                    },
                  ),
                ],
              ),
              ExpandableSettingsTile(
                title: 'Quick setting 2',
                subtitle: 'Expandable Settings',
                children: <Widget>[
                  CheckboxSettingsTile(
                    settingKey: 'key-day-light-savings-2',
                    title: 'Daylight Time Saving',
                    enabledLabel: 'Enabled',
                    disabledLabel: 'Disabled',
                    leading: Icon(Icons.timelapse),
                    onChange: (value) {
                      debugPrint('key-day-light-savings-2: $value');
                    },
                  ),
                  SwitchSettingsTile(
                    settingKey: 'key-dark-mode-2',
                    title: 'Dark Mode',
                    enabledLabel: 'Enabled',
                    disabledLabel: 'Disabled',
                    leading: Icon(Icons.palette),
                    onChange: (value) {
                      debugPrint('key-dark-mode-2: $value');
                    },
                  ),
                ],
              ),
            ],
          ),
          SettingsGroup(
            title: 'Multiple choice settings',
            children: <Widget>[
              RadioSettingsTile<int>(
                title: 'Preferred Sync Period',
                settingKey: 'key-radio-sync-period',
                values: <int, String>{
                  0: 'Never',
                  1: 'Daily',
                  7: 'Weekly',
                  15: 'Fortnight',
                  30: 'Monthly',
                },
                selected: 0,
                onChange: (value) {
                  debugPrint('key-radio-sync-period: $value');
                },
              ),
              DropDownSettingsTile<int>(
                title: 'E-Mail View',
                settingKey: 'key-dropdown-email-view',
                values: <int, String>{
                  2: 'Simple',
                  3: 'Adjusted',
                  4: 'Normal',
                  5: 'Compact',
                  6: 'Squizzed',
                },
                selected: 2,
                onChange: (value) {
                  debugPrint('key-dropdown-email-view: $value');
                },
              ),
            ],
          ),
          ModalSettingsTile(
            title: 'Group Settings',
            subtitle: 'Same group settings but in a dialog',
            children: <Widget>[
              SimpleRadioSettingsTile(
                title: 'Sync Settings',
                settingKey: 'key-radio-sync-settings',
                values: <String>[
                  'Never',
                  'Daily',
                  'Weekly',
                  'Fortnight',
                  'Monthly',
                ],
                selected: 'Daily',
                onChange: (value) {
                  debugPrint('key-radio-sync-settins: $value');
                },
              ),
              SimpleDropDownSettingsTile(
                title: 'Beauty Filter',
                settingKey: 'key-dropdown-beauty-filter',
                values: <String>[
                  'Simple',
                  'Normal',
                  'Little Special',
                  'Special',
                  'Extra Special',
                  'Bizzar',
                  'Horrific',
                ],
                selected: 'Special',
                onChange: (value) {
                  debugPrint('key-dropdown-beauty-filter: $value');
                },
              )
            ],
          ),
          ExpandableSettingsTile(
            title: 'Expandable Group Settings',
            subtitle: 'Group of settings (expandable)',
            children: <Widget>[
              RadioSettingsTile<double>(
                title: 'Beauty Filter',
                settingKey: 'key-radio-beauty-filter-exapndable',
                values: <double, String>{
                  1.0: 'Simple',
                  1.5: 'Normal',
                  2.0: 'Little Special',
                  2.5: 'Special',
                  3.0: 'Extra Special',
                  3.5: 'Bizzar',
                  4.0: 'Horrific',
                },
                selected: 2.5,
                onChange: (value) {
                  debugPrint('key-radio-beauty-filter-expandable: $value');
                },
              ),
              DropDownSettingsTile<int>(
                title: 'Preferred Sync Period',
                settingKey: 'key-dropdown-sync-period-2',
                values: <int, String>{
                  0: 'Never',
                  1: 'Daily',
                  7: 'Weekly',
                  15: 'Fortnight',
                  30: 'Monthly',
                },
                selected: 0,
                onChange: (value) {
                  debugPrint('key-dropdown-sync-period-2: $value');
                },
              )
            ],
          ),
          SettingsGroup(
            title: 'Other settings',
            children: <Widget>[
              SliderSettingsTile(
                title: 'Volume',
                settingKey: 'key-slider-volume',
                defaultValue: 20,
                min: 0,
                max: 100,
                step: 1,
                leading: Icon(Icons.volume_up),
                onChange: (value) {
                  debugPrint('key-slider-volume: $value');
                },
              ),
              ColorPickerSettingsTile(
                settingKey: 'key-color-picker',
                title: 'Accent Color',
                defaultValue: Colors.blue,
                onChange: (value) {
                  debugPrint('key-color-picker: $value');
                },
              )
            ],
          ),
          ModalSettingsTile(
            title: 'Other settings',
            subtitle: 'Other Settings in a Dialog',
            children: <Widget>[
              SliderSettingsTile(
                title: 'Custom Ratio',
                settingKey: 'key-custom-ratio-slider-2',
                defaultValue: 2.5,
                min: 1,
                max: 5,
                step: 0.1,
                leading: Icon(Icons.aspect_ratio),
                onChange: (value) {
                  debugPrint('key-custom-ratio-slider-2: $value');
                },
              ),
              MaterialColorPickerSettingsTile(
                settingKey: 'key-color-picker-2',
                title: 'Accent Picker',
                defaultValue: Colors.blue,
                onChange: (value) {
                  debugPrint('key-color-picker-2: $value');
                },
              )
            ],
          )
        ],
      ),
    );

  }
}*/