//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'dart:typed_data';
import 'package:dmrtd/extensions.dart';
import 'package:dmrtd/src/com/com_provider.dart';
import 'package:dmrtd/src/tlv.dart';
import 'package:dmrtd/src/utils.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'command_apdu.dart';
import 'iso7816.dart';
import 'response_apdu.dart';
import 'sm.dart';

class ICCError implements Exception {
  final String message;
  final StatusWord sw;
  ICCError(this.message, this.sw);
  String toString() => 'ICC Error: $message $sw';
}


/// Defines ISO/IEC-7816 ICC API interface to send commands and receive data.
class ICC {
  final ComProvider _com;
  final _log = Logger("icc");
  SecureMessaging sm;  

  ICC(this._com);

  /// Can throw [ComProviderError].
  Future<void> connect() async {
    return await _com.connect();
  }

  /// Can throw [ComProviderError].
  Future<void> disconnect() async {
    return await _com.disconnect();
  }

  bool isConnected() {
    return _com.isConnected();
  }

  /// Sends EXTERNAL AUTHENTICATE command to ICC.
  /// ICC should return it's computed authentication data.
  /// Can throw [ICCError] or [ComProviderError].
  Future<Uint8List> externalAuthenticate({ @required Uint8List data, @required int ne, int cla: ISO7816_CLA.NO_SM }) async {
    final rapdu = await _transceive(
      CommandAPDU(cla: cla, ins: ISO7816_INS.EXTERNAL_AUTHENTICATE, p1: 0x00, p2: 0x00, data: data, ne: ne)
    );
    if(rapdu.status != StatusWord.success) {
      throw ICCError("External authenticate failed", rapdu.status);
    }
    return rapdu.data;
  }

  /// Sends INTERNAL AUTHENTICATE command to ICC.
  /// ICC should return it's computed authentication data.
  /// Can throw [ICCError] or [ComProviderError].
  Future<Uint8List> internalAuthenticate({ @required Uint8List data, int p1 = 0x00, int p2 = 0x00, @required int ne, int cla: ISO7816_CLA.NO_SM }) async {
    final rapdu = await _transceive(
      CommandAPDU(cla: cla, ins: ISO7816_INS.INTERNAL_AUTHENTICATE, p1: p1, p2: p2, data: data, ne: ne)
    );
    if(rapdu.status != StatusWord.success) {
      throw ICCError("Internal authenticate failed", rapdu.status);
    }
    return rapdu.data;
  }

  /// Sends GET CHALLENGE command to ICC and ICC should return
  /// [challengeLength] long challenge. 
  /// Can throw [ICCError] or [ComProviderError].
  Future<Uint8List> getChallenge({ @required int challengeLength, int cla: ISO7816_CLA.NO_SM }) async {
    final rapdu = await _transceive(
      CommandAPDU(cla: cla, ins: ISO7816_INS.GET_CHALLENGE, p1: 0x00, p2: 0x00, ne: challengeLength)
    );
    if(rapdu.status != StatusWord.success) {
      throw ICCError("Get challenge failed", rapdu.status);
    }
    return rapdu.data;
  }

  /// Sends READ BINARY command to ICC.
  /// It returns [ne] long chunk of data of a file at [offset].
  /// Max [offset] can be 32 767. [ne] must not overlap 32 767 offset.
  /// Can throw [ICCError] or [ComProviderError].
  /// 
  /// Note: Use [readBinaryExt] to read data chunks at offsets greater than 32 767.
  Future<Uint8List> readBinary({ @required int offset, @required int ne, int cla: ISO7816_CLA.NO_SM}) async {
    if(offset >  32767) {
      throw ArgumentError.value(offset, null, "Max read binary offset can be 32 767 bytes");
    }

    Uint8List rawOffset = Utils.intToBin(offset, minLen: 2);
    final p1 = rawOffset[0];
    final p2 = rawOffset[1];

    final rapdu = await _transceive(
      CommandAPDU(cla: cla, ins: ISO7816_INS.READ_BINARY, p1: p1, p2: p2, ne: ne)
    );
    if(rapdu.status != StatusWord.success) {
      throw ICCError("Read binary failed", rapdu.status);
    }
    return rapdu.data;
  }

  /// Sends READ BINARY command to ICC.
  /// It returns file's [ne] long chunk of data at [offset].
  /// File is identified by [sfi].
  /// Max [offset] can be  256 bytes.
  /// Can throw [ICCError] or [ComProviderError].
  Future<Uint8List> readBinaryBySFI({ @required int sfi, @required int offset, @required int ne, int cla: ISO7816_CLA.NO_SM}) async {
    if(offset >  255) {
      throw ArgumentError.value(offset, null, "readBinaryBySFI: Max offset can be 256 bytes");
    }
    if((sfi & 0x80) == 0) { // bit 8 must be set
      throw ArgumentError.value(offset, null, "readBinaryBySFI: Invalid SFI identifier");
    }

    final rapdu = await _transceive(
      CommandAPDU(cla: cla, ins: ISO7816_INS.READ_BINARY, p1: sfi, p2: offset, ne: ne)
    );
    if(rapdu.status != StatusWord.success) {
      throw ICCError("Read read binary by SFI", rapdu.status);
    }
    return rapdu.data;
  }

  /// Sends Extended READ BINARY command to ICC.
  /// It returns [ne] long chunk of data of a file at [offset].
  /// [offset] must be 32 768 or greater.
  /// Can throw [ICCError] or [ComProviderError].
  Future<Uint8List> readBinaryExt({ @required int offset, @required int ne, int cla: ISO7816_CLA.NO_SM}) async {
    if(offset < 0x8000) {
      throw ArgumentError.value(offset, null, "readBinaryExt: Invalid offset");
    }

    final data  =  TLV.encodeIntValue(0x54, offset);
    final rapdu = await _transceive(
      CommandAPDU(cla: cla, ins: ISO7816_INS.READ_BINARY_EXT, p1: 0x00, p2: 0x00, data: data, ne: ne)
    );
    if(rapdu.status != StatusWord.success) {
      throw ICCError("Read binary failed", rapdu.status);
    }
    return rapdu.data;
  }

  /// Sends SELECT FILE command to ICC.
  /// Can throw [ICCError] or [ComProviderError].
  Future<Uint8List> selectFile({ @required int p1, @required int p2, int cla: ISO7816_CLA.NO_SM, Uint8List data, int ne = 0}) async {
    final rapdu = await _transceive(
      CommandAPDU(cla: cla, ins: ISO7816_INS.SELECT_FILE, p1: p1, p2: p2, data: data, ne: ne)
    );
    if(rapdu.status != StatusWord.success) {
      throw ICCError("Select File failed", rapdu.status);
    }
    return rapdu.data;
  }

  /// Selects MF, DF or EF by file ID.
  /// If [fileId] is null, then MF is selected.
  /// Can throw [ICCError] or [ComProviderError].
  Future<Uint8List> selectFileById({ @required Uint8List fileId, int p2 = 0, int cla: ISO7816_CLA.NO_SM, int ne = 0}) async {
    return await selectFile(cla: cla, p1: ISO97816_SelectFileP1.byID, p2: p2, data: fileId, ne: ne);
  }

  /// Selects child DF by [childDF] ID.
  /// Can throw [ICCError] or [ComProviderError].
  Future<Uint8List> selectChildDF({ @required Uint8List childDF, int p2 = 0, int cla: ISO7816_CLA.NO_SM, int ne = 0}) async {
    return await selectFile(cla: cla, p1: ISO97816_SelectFileP1.byChildDFID, p2: p2, data: childDF, ne: ne);
  }

  /// Selects EF under current DF by [efId].
  /// Can throw [ICCError] or [ComProviderError].
  Future<Uint8List> selectEF({ @required Uint8List efId, int p2 = 0, int cla: ISO7816_CLA.NO_SM, int ne = 0}) async {
    return await selectFile(cla: cla, p1: ISO97816_SelectFileP1.byEFID, p2: p2, data: efId, ne: ne);
  }

  /// Selects parent DF under current DF.
  /// Can throw [ICCError] or [ComProviderError].
  Future<Uint8List> selectParentDF({ int p2 = 0, int cla: ISO7816_CLA.NO_SM, int ne = 0}) async {
    return await selectFile(cla: cla, p1: ISO97816_SelectFileP1.parentDF, p2: p2, ne: ne);
  }

  /// Selects file by DF name
  /// Can throw [ICCError] or [ComProviderError].
  Future<Uint8List> selectFileByDFName({ @required Uint8List dfName, int p2 = 0, int cla: ISO7816_CLA.NO_SM, int ne = 0}) async {
    return await selectFile(cla: cla, p1: ISO97816_SelectFileP1.byDFName, p2: p2, data: dfName, ne: ne);
  }

  /// Selects file by [path].
  /// If [fromMF] is true, then is selected by [path] starting from MF, otherwise from currentDF.
  /// [path] must not include MF/Current DF ID. 
  /// Can throw [ICCError] or [ComProviderError].
  Future<Uint8List> selectFileByPath({ @required Uint8List path, bool fromMF, int p2 = 0, int cla: ISO7816_CLA.NO_SM, int ne = 0}) async {
    final p1 = fromMF ? ISO97816_SelectFileP1.byPathFromMF : ISO97816_SelectFileP1.byPath;
    return await selectFile(cla: cla, p1: p1, p2: p2, data: path, ne: ne);
  }


  /// Can throw [ICCError].
  Future<ResponseAPDU> _transceive(final CommandAPDU cmd) async {
    final rawCmd = _wrap(cmd).toBytes();
    _log.verbose("Sending bytes to ICC: len=${rawCmd.length} data='${rawCmd.hex()}'");
    Uint8List rawResp = await _com.transceive(rawCmd);

    final rapdu = _unwrap(ResponseAPDU.fromBytes(rawResp));
    _log.verbose("Received response from ICC: $rapdu");
    return rapdu;
  }

  CommandAPDU _wrap(final CommandAPDU cmd) {
    if(sm != null) {
      return sm.protect(cmd);
    }
    return cmd;
  }

  ResponseAPDU _unwrap(final ResponseAPDU resp) {
    if(sm != null) {
      return sm.unprotect(resp);
    }
    return resp;
  }
}
