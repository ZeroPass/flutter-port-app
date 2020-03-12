//  Created by smlu on 12/02/2020.
//  Copyright © 2020 ZeroPass. All rights reserved.
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import '../ef/mrz.dart';
import '../extension/datetime_apis.dart';
import '../extension/string_apis.dart';

class BACKeySeed {
    String _mrtdNum;
    String _dob;
    String _doe;
    
    BACKeySeed(String mrtdNumber, DateTime dateOfBirth, DateTime dateOfExpiry) {
      _mrtdNum = mrtdNumber;
      _dob     = dateOfBirth.formatYYMMDD();
      _doe     = dateOfExpiry.formatYYMMDD();
    }

    factory BACKeySeed.fromMRZ(MRZ mrz) {
      return BACKeySeed(mrz.documentNumber, mrz.dateOfBirth, mrz.dateOfExpiry);
    }
    
    String mrtdNumber() {
      return _mrtdNum;
    }
    
    DateTime dateOfBirth() {
      return _dob.parseDateYYMMDD();
    }
    
    DateTime dateOfExpiry() {
      return _doe.parseDateYYMMDD();
    }
    
    Uint8List keySeed() {
      final paddedMrtdNum = _mrtdNum.padRight(9, '<');
      final cdn = MRZ.calculateCheckDigit(paddedMrtdNum);
      final cdb = MRZ.calculateCheckDigit(_dob);
      final cde = MRZ.calculateCheckDigit(_doe);
      
      final kmrz = "$paddedMrtdNum$cdn$_dob$cdb$_doe$cde";
      final hash = sha1.convert(kmrz.codeUnits);
      return hash.bytes.sublist(0, 16);
    }
}