//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.

import 'dart:typed_data';
import 'package:test/test.dart';

import 'package:dmrtd/src/com/command_apdu.dart';
import 'package:dmrtd/src/com/response_apdu.dart';
import 'package:dmrtd/src/extension/string_apis.dart';

void main() {
  test('Command APDU test', () {
    // Test vectors from https://www.openscdp.org/sse4e/isosecurechannel.html
    expect( CommandAPDU(cla: 0x00, ins: 0x10, p1: 0x20, p2: 0x30).toBytes()                                         , "00102030".parseHex()               ); // Case 1 Command APDU
    expect( CommandAPDU(cla: 0x00, ins: 0x10, p1: 0x20, p2: 0x30, ne: 0x80).toBytes()                               , "0010203080".parseHex()             ); // Case 2s Command APDU
    expect( CommandAPDU(cla: 0x00, ins: 0x10, p1: 0x20, p2: 0x30, ne: 0x180).toBytes()                              , "00102030000180".parseHex()         ); // Case 2e Command APDU
    expect( CommandAPDU(cla: 0x00, ins: 0x10, p1: 0x20, p2: 0x30, data: "41424344".parseHex()).toBytes()            , "001020300441424344".parseHex()     ); // Case 3s Command APDU
    expect( CommandAPDU(cla: 0x00, ins: 0x10, p1: 0x20, p2: 0x30, data: "41424344".parseHex(), ne: 0x80).toBytes()  , "00102030044142434480".parseHex()   ); // Case 4s Command APDU
    expect( CommandAPDU(cla: 0x00, ins: 0x10, p1: 0x20, p2: 0x30, data: "41424344".parseHex(), ne: 0x180).toBytes() , "0010203004414243440180".parseHex() ); // Case 4s Command APDU
  });

  test('Response APDU test', () {
    // Test vectors from ICAO 9303 p11 appendix D.4
    // Test 1
    var rapdu = ResponseAPDU("990290008E08FA855A5D4C50A8ED9000".parseHex());
    expect( rapdu.sw1  , 0x90 );
    expect( rapdu.sw2  , 0x00 );
    expect( rapdu.data , "990290008E08FA855A5D4C50A8ED".parseHex() );

    // Test 2
    rapdu = ResponseAPDU("8709019FF0EC34F9922651990290008E08AD55CC17140B2DED9000".parseHex());
    expect( rapdu.sw1  , 0x90 );
    expect( rapdu.sw2  , 0x00 );
    expect( rapdu.data , "8709019FF0EC34F9922651990290008E08AD55CC17140B2DED".parseHex() );

    // Test 3
    rapdu = ResponseAPDU("871901FB9235F4E4037F2327DCC8964F1F9B8C30F42C8E2FFF224A990290008E08C8B2787EAEA07D749000".parseHex());
    expect( rapdu.sw1  , 0x90 );
    expect( rapdu.sw2  , 0x00 );
    expect( rapdu.data , "871901FB9235F4E4037F2327DCC8964F1F9B8C30F42C8E2FFF224A990290008E08C8B2787EAEA07D74".parseHex() );
  
    // Test response status word
    rapdu = ResponseAPDU("9000".parseHex());
    expect( rapdu.sw1  , 0x90 );
    expect( rapdu.sw2  , 0x00 );
    expect( rapdu.data , null );

    rapdu = ResponseAPDU("6A80".parseHex());
    expect( rapdu.sw1  , 0x6A );
    expect( rapdu.sw2  , 0x80 );
    expect( rapdu.data , null );

    rapdu = ResponseAPDU("6A88".parseHex());
    expect( rapdu.sw1  , 0x6A );
    expect( rapdu.sw2  , 0x88 );
    expect( rapdu.data , null );

    rapdu = ResponseAPDU("6300".parseHex());
    expect( rapdu.sw1  , 0x63 );
    expect( rapdu.sw2  , 0x00 );
    expect( rapdu.data , null );

    rapdu = ResponseAPDU(Uint8List(2));
    expect( rapdu.sw1  , 0x00 );
    expect( rapdu.sw2  , 0x00 );
    expect( rapdu.data , null );

    rapdu = ResponseAPDU("FFFF".parseHex());
    expect( rapdu.sw1  , 0xFF );
    expect( rapdu.sw2  , 0xFF );
    expect( rapdu.data , null );

    expect( () =>  ResponseAPDU(null), throwsArgumentError );
    expect( () =>  ResponseAPDU(Uint8List(0)), throwsArgumentError );
    expect( () =>  ResponseAPDU(Uint8List(1)), throwsArgumentError );
  });
}