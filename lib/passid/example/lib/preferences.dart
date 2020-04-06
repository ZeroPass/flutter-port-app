//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'dart:convert';
import 'package:dmrtd/dmrtd.dart';
import 'package:dmrtd/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {

  static final Uri defaltServerUrl     = Uri.parse("https://127.0.0.1:443");
  static const Duration defaultTimeout = const Duration(seconds:5); // sec

  static const String _srvUrl  = "serverUrl";
  static const String _timeout = "timeout";
  static const String _dbakeys = "dbaKeys";

  static SharedPreferences _prefs;

  static void init() async {
    if(_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  static DBAKeys getDBAKeys() {
    final data = _prefs.getString(_dbakeys);
    if(data == null) {
      return null;
    }
    final jkeys = jsonDecode(data);
    return DBAKeys(
      jkeys['mrtd_num'],
      (jkeys['dob'] as String).parseDateYYMMDD(),
      (jkeys['doe'] as String).parseDateYYMMDD()
    );
  }

  static Future<bool> setDBAKeys(final DBAKeys keys) {
    final data = jsonEncode({
      'mrtd_num' : keys.mrtdNumber,
      'dob'      : keys.dateOfBirth.formatYYMMDD(),
      'doe'      : keys.dateOfExpiry.formatYYMMDD()
    });
    return _prefs.setString(_dbakeys, data);
  }

  static Uri getServerUrl()  {
    final url = _prefs.getString(_srvUrl);
    if(url != null) {
      return Uri.parse(url);
    }
    return  defaltServerUrl;
  }

  static Future<bool> setServerUrl(Uri url) async {
    return _prefs.setString(_srvUrl, url.toString());
  }

  static Duration getConnectionTimeout() {
    return Duration(seconds: _prefs.getInt(_timeout) ?? defaultTimeout.inSeconds);
  }

  static Future<bool> setConnectionTimeout(Duration timeout) async {
    return _prefs.setInt(_timeout, timeout.inSeconds);
  }
}