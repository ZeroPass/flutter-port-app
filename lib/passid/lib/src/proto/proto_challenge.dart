//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'dart:typed_data';
import 'package:dmrtd/extensions.dart';

// Represents proto challenge id
class CID {
  static const _serKey = 'cid';
  final Uint8List value;

  CID(this.value) {
    if (value.length != 4) {
      throw ArgumentError.value(value, '', 'Invalid raw CID bytes length');
    }
  }

  factory CID.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey(_serKey)) {
      throw ArgumentError.value(json, 'json',
          "Can't construct CID from JSON, no key '$_serKey' in argument");
    }
    return CID((json[_serKey] as String).parseHex());
  }

  Map<String, dynamic> toJson() {
    return {_serKey: value.hex()};
  }

  int toInt() {
    return ByteData.view(value.buffer).getUint32(0, Endian.big);
  }
}

class ProtoChallenge {
  static const _serKey = 'challenge';
  final Uint8List data;

  CID get id {
    return CID(data.sublist(0, 4));
  }

  ProtoChallenge(this.data) {
    if (data.length != 32) {
      throw ArgumentError.value(data, '', 'Invalid raw challenge bytes length');
    }
  }

  factory ProtoChallenge.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey(_serKey)) {
      throw ArgumentError.value(json, 'json',
          "Can't construct ProtoChallenge from JSON, no key '$_serKey' in argument");
    }
    return ProtoChallenge((json[_serKey] as String).parseBase64());
  }

  /// Returns list of [chunkSize] big chunks of challenge bytes.
  List<Uint8List> getChunks(int chunkSize) {
    if(data.length % chunkSize != 0) {
      throw ArgumentError.value(chunkSize, null, 'Invalid chunk size');
    }

    final chunks = <Uint8List>[];
    for(int i = 0; i < data.length; i += chunkSize) {
      final c = data.sublist(i,  i + chunkSize);
      chunks.add(Uint8List.fromList(c));
    }
    return chunks;
  }

  Map<String, dynamic> toJson() {
    return {_serKey: data.base64()};
  }
}