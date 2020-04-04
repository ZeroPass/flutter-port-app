//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dmrtd/extensions.dart';
import 'package:meta/meta.dart';

import 'session_key.dart';
import 'uid.dart';

class SessionMac  {
  
  static const _serKey = 'mac';
  Uint8List _mac;
    
  SessionMac(final Uint8List rawMac) {
    if(rawMac.length != 32) {
      throw ArgumentError.value(rawMac, 'rawMac', 'Invalid length');
    }
    _mac = rawMac;
  }
  
  factory SessionMac.fromJson(final Map<String, dynamic> json) {
    if (!json.containsKey(_serKey)) {
    throw ArgumentError.value(json, 'json',
      "Can't construct SessionMac from JSON, no key '$_serKey' in argument");
    }
    return SessionMac((json[_serKey] as String).parseBase64());
  }

  Map<String, dynamic> toJson() {
    return {_serKey: _mac.base64()};
  }
}


class Session {
  //typealias hmac = HMAC<SHA256>
  
  final UserId uid;
  final SessionKey key;
  final DateTime expiry;
  int _nonce = 0;

  Session({@required this.uid, @required this.key, @required this.expiry});
  factory Session.fromJson(final Map<String, dynamic> json, {UserId uid}) {
    uid = uid ?? UserId.fromJson(json);
    final key = SessionKey.fromJson(json);

    if (!json.containsKey('expires')) {
    throw ArgumentError.value(json, 'json',
      "Can't construct Session from JSON, no key 'expires' in argument");
    }

    final expiry = json['expires'] as int;
    return Session(uid: uid, key: key,
      expiry: DateTime.fromMillisecondsSinceEpoch(expiry * 1000)
    );
  }
  
  SessionMac calculateMAC({ @required String apiName, @required Uint8List rawParams }) {
      // TODO: make log
    final msg = _getEncodedNonce() + apiName.codeUnits + rawParams;
    _incrementNonce();
    return SessionMac(_calculateMac(msg));
  }

  @override
  String toString() {
    return 'uid: $uid '
           "expires: '${expiry.toLocal()}' "
           'key: ${key.toBytes().hex()}';
  }

  Uint8List _calculateMac(final List<int> msg) {
    final mac = Hmac(sha256, key.toBytes())
      .convert(msg).bytes;
    return Uint8List.fromList(mac);
  }

  void _incrementNonce() {
      _nonce += 1;
      if(_nonce > 0xFFFFFFFF) {
        _nonce = 0;
      }
  }

  Uint8List _getEncodedNonce()  {
    final encoded = Uint8List(4);
    ByteData.view(encoded.buffer)
      .setUint32(0, _nonce, Endian.big); // Note: potentially could overflow buffer
    return encoded;
  }
}