//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'dart:typed_data';
import 'package:dmrtd/extensions.dart';

class SessionKey  {
  static const _serKey = 'session_key';
  Uint8List _key;
    
  SessionKey(final Uint8List rawKey) {
    if(rawKey.length != 32) {
      throw ArgumentError.value(rawKey, 'rawKey', 'Invalid length');
    }
    _key = rawKey;
  }
  
  factory SessionKey.fromJson(final Map<String, dynamic> json) {
    if (!json.containsKey(_serKey)) {
    throw ArgumentError.value(json, 'json',
      "Can't construct SessionKey from JSON, no key '$_serKey' in argument");
    }
    return SessionKey((json[_serKey] as String).parseBase64());
  }

  Uint8List toBytes() =>_key;

  Map<String, dynamic> toJson() {
    return {_serKey: _key.base64()};
  }
}