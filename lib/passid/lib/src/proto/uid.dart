//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'dart:typed_data';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:dmrtd/dmrtd.dart';
import 'package:dmrtd/extensions.dart';

class UserId  {
  static const _serKey = 'uid';
  Uint8List _uid;

  UserId(final Uint8List rawUid) {
    if(rawUid.length != RIPEMD160Digest().digestSize) {
      throw ArgumentError.value(rawUid, 'rawUid', 'Invalid length');
    }
    _uid = rawUid;
  }

  factory UserId.fromDG15(final EfDG15 dg15) {
    return UserId(RIPEMD160Digest().process(dg15.aaPublicKey.toBytes()));
  }

  factory UserId.fromJson(final Map<String, dynamic> json) {
    if (!json.containsKey(_serKey)) {
    throw ArgumentError.value(json, 'json',
      "Can't construct UserId from JSON, no key '$_serKey' in argument");
    }
    return UserId((json[_serKey] as String).parseBase64());
  }

  Uint8List toBytes() => _uid;

  Map<String, dynamic> toJson() {
    return {_serKey: _uid.base64()};
  }

  @override
  String toString() => _uid.hex();
}