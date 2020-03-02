//  Created by smlu on 12/02/2020.
//  Copyright © 2020 ZeroPass. All rights reserved.
import 'dart:typed_data';
import 'package:test/test.dart';

import 'package:dmrtd/src/ef/mrz.dart';
import 'package:dmrtd/src/extension/string_apis.dart';
import 'package:dmrtd/src/proto/bac_keyseed.dart';

void main() {
  test('BAC key seed test', () {
    // Test vectors taken from: https://www.icao.int/publications/Documents/9303_p11_cons_en.pdf Appendix D to Part 11  section D.2
    var mrz = MRZ(Uint8List.fromList("I<UTOSTEVENSON<<PETER<JOHN<<<<<<<<<<D23145890<UTO3407127M95071227349<<<8".codeUnits));
    expect( BACKeySeed(mrz.documentNumber, mrz.dateOfBirth, mrz.dateOfExpiry).keySeed() , "b366ad857ddca2b08c0e299811714730".parseHex()         );
  
    mrz = MRZ(Uint8List.fromList("I<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<L898902C<3UTO6908061F9406236<<<<<<<2".codeUnits)); // Note: composite CD changed from 8 to 2
    expect( BACKeySeed(mrz.documentNumber, mrz.dateOfBirth, mrz.dateOfExpiry).keySeed() , "239ab9cb282daf66231dc5a4df6bfbae".parseHex()         );

    mrz = MRZ(Uint8List.fromList("I<UTOD23145890<7349<<<<<<<<<<<3407127M9507122UTO<<<<<<<<<<<2STEVENSON<<PETER<JOHN<<<<<<<<<".codeUnits));
    expect( BACKeySeed(mrz.documentNumber, mrz.dateOfBirth, mrz.dateOfExpiry).keySeed() , "b366ad857ddca2b08c0e299811714730".parseHex()         );
  
    mrz = MRZ(Uint8List.fromList("I<UTOL898902C<3<<<<<<<<<<<<<<<6908061F9406236UTO<<<<<<<<<<<2ERIKSSON<<ANNA<MARIA<<<<<<<<<<".codeUnits)); // Note: Composite CD changed from 1 to 2
    expect( BACKeySeed(mrz.documentNumber, mrz.dateOfBirth, mrz.dateOfExpiry).keySeed() , "239AB9CB282DAF66231DC5A4DF6BFBAE".parseHex()         );
  });
}