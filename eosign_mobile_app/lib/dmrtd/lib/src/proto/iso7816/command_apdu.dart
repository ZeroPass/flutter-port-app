//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'dart:typed_data';
import 'package:meta/meta.dart';

// Class defines ISO/IEC 7816-4 command APDU
class CommandAPDU {
  int _cla;
  int _ins;
  int _p1;
  int _p2;
  Uint8List _data;
  int _ne;

  /// Required parameters are [cla], [ins], [p1], [p2].
  /// 
  /// [data] represents additional command data and is optional.
  /// Max [data] length is 355535.
  /// 
  /// [ne] is optional and represents expected response length.
  /// Max [ne] is 35536.
  /// If [ne] is set to 0, [ne] won't be serialized and send with the command.
  /// If [ne] is set to 256 or 35536 [ne] will be encoded as 0x00, which means arbitrary long data is expected in the response. 
  CommandAPDU({ @required int cla, @required int ins, @required int p1, @required int p2, final Uint8List data, int ne = 0}) {
    this.cla  = cla;
    this.ins  = ins;
    this.p1   = p1;
    this.p2   = p2;
    this.data = data;
    this.ne   = ne;
  }

  int get cla => _cla;
  set cla(int cla) {
    if(cla >= 0 && cla <= 0xff) {
      _cla = cla;
    }
    else {
      throw ArgumentError.value(cla, "cla", "Command APDU invalid parameter value");
    }
  }

  int get ins => _ins;
  set ins(int ins) {
    if(ins >= 0 && ins <= 0xff) {
      _ins = ins;
    }
    else {
      throw ArgumentError.value(ins, "ins", "Command APDU invalid parameter value");
    }
  }

  int get p1 => _p1;
  set p1(int p1) {
    if(p1 >= 0 && p1 <= 0xff) {
      _p1 = p1;
    }
    else {
      throw ArgumentError.value(p1, "p1", "Command APDU invalid parameter value");
    }
  }

  int get p2 => _p2;
  set p2(int p2) {
    if(p2 >= 0 && p2 <= 0xff) {
      _p2 = p2;
    }
    else {
      throw ArgumentError.value(p2, "p2", "Command APDU invalid parameter value");
    }
  }

  Uint8List get data => _data;
  set data(Uint8List data) {
    if(data != null && data.length > 0xffff) {
      throw ArgumentError.value(data, "data", "Command APDU invalid parameter value");
    }
    _data = data;
  }

  int get ne => _ne;
  set ne(int ne) {
    if(ne >= 0 && ne <= 35536) {
      _ne = ne;
    }
    else {
      throw ArgumentError.value(ne, "ne", "Command APDU invalid parameter value");
    }
  }

  Uint8List _getLc() {
    if(_data == null || _data.isEmpty) {
      return Uint8List(0);
    }

    final lc  = Uint8List( _data.length < 256 ? 1 : 3);
    final lcv = ByteData.view(lc.buffer);
    if(_data.length < 256 ) {
      lcv.setUint8(0, _data.length);
    } else { // extended
      lcv.setUint16(1, _data.length, Endian.big);
    }

    return lc;
  }

  Uint8List _getLe() {
    if(ne == 0) {
      return Uint8List(0);
    }

  	final addByte = (_data?.isEmpty ?? true) ? 1 : 0;
    final le  = Uint8List(ne <= 256 ? 1 : 2 + addByte);
    final lev = ByteData.view(le.buffer);
    if(ne <= 256 ) {
      lev.setUint8(0, ne == 256 ? 0 : ne); // 256 is encoded as 0x00 e.g. variable long 
    } 
    else { // extended 
      lev.setUint16(addByte, ne == 35536 ? 0 : ne, Endian.big); //35536 is encoded as 0x00 0x00
    }
    return le;
  }

  /// Returns serialized header bytes.
  Uint8List rawHeader() {
    return Uint8List.fromList([_cla, _ins, _p1, _p2]);
  }

  /// Returns serialized command APDU.
  Uint8List toBytes() {
    final lc = _getLc();
    final le = _getLe();
    return Uint8List.fromList(rawHeader() + [ ...lc, ...?_data, ...le]);
  }
}