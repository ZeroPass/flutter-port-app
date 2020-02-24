//  Created by smlu on 17/02/2020.
//  Copyright © 2020 ZeroPass. All rights reserved.
import 'dart:typed_data';
import 'des.dart';

/// Class defines ISO/IEC 9797-1 padding method 2.
class ISO9797 {

  // Returns padded data according to ISO/IEC 9797-1, padding method 2 scheme.
  static Uint8List pad(Uint8List data) {
    final Uint8List padBlock = Uint8List.fromList([0x80, 0, 0, 0, 0, 0, 0, 0]);
    final padSize = DESCipher.blockSize - (data.length % DESCipher.blockSize);
    return Uint8List.fromList(data + padBlock.sublist(0, padSize));
  }

  // Returns unpadded data according to ISO/IEC 9797-1, padding method 2 scheme.
  static Uint8List unpad(Uint8List data) {
    var i = data.length - 1;
      while (data[i] == 0x00) {
          i -= 1;
      }
      if(data[i] == 0x80) {
        return data.sublist(0, i);
      }
      return data;
  }
}