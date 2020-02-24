//  Created by smlu on 18/02/2020.
//  Copyright © 2020 ZeroPass. All rights reserved.

import 'package:flutter_test/flutter_test.dart';

import '../../lib/dmrtd/crypto/iso9797.dart';
import '../../lib/dmrtd/extension/string_apis.dart';


void main() {
  test('ISO9797 padding method 2', () {
    var tv       = "".parseHex();
    var tvPadded = "8000000000000000".parseHex();
    expect( ISO9797.pad(tv)        , tvPadded );
    expect( ISO9797.unpad(tvPadded), tv       );

    tv       = "0001020304050607".parseHex();
    tvPadded = "00010203040506078000000000000000".parseHex();
    expect( ISO9797.pad(tv)        , tvPadded );
    expect( ISO9797.unpad(tvPadded), tv       );

    tv       = "000102030405060708".parseHex();
    tvPadded = "00010203040506070880000000000000".parseHex();
    expect( ISO9797.pad(tv)        , tvPadded );
    expect( ISO9797.unpad(tvPadded), tv       );

    tv       = "00010203040506070809".parseHex();
    tvPadded = "00010203040506070809800000000000".parseHex();
    expect( ISO9797.pad(tv)        , tvPadded );
    expect( ISO9797.unpad(tvPadded), tv       );

    tv       = "000102030405060708090A".parseHex();
    tvPadded = "000102030405060708090A8000000000".parseHex();
    expect( ISO9797.pad(tv)        , tvPadded );
    expect( ISO9797.unpad(tvPadded), tv       );

    tv       = "000102030405060708090A0B".parseHex();
    tvPadded = "000102030405060708090A0B80000000".parseHex();
    expect( ISO9797.pad(tv)        , tvPadded );
    expect( ISO9797.unpad(tvPadded), tv       );

    tv       = "000102030405060708090A0B0C".parseHex();
    tvPadded = "000102030405060708090A0B0C800000".parseHex();
    expect( ISO9797.pad(tv)        , tvPadded );
    expect( ISO9797.unpad(tvPadded), tv       );

    tv       = "000102030405060708090A0B0C0D".parseHex();
    tvPadded = "000102030405060708090A0B0C0D8000".parseHex();
    expect( ISO9797.pad(tv)        , tvPadded );
    expect( ISO9797.unpad(tvPadded), tv       );

    tv       = "000102030405060708090A0B0C0D0E".parseHex();
    tvPadded = "000102030405060708090A0B0C0D0E80".parseHex();
    expect( ISO9797.pad(tv)        , tvPadded );
    expect( ISO9797.unpad(tvPadded), tv       );

    tv       = "000102030405060708090A0B0C0D0E0F".parseHex();
    tvPadded = "000102030405060708090A0B0C0D0E0F8000000000000000".parseHex();
    expect( ISO9797.pad(tv)        , tvPadded );
    expect( ISO9797.unpad(tvPadded), tv       );
  });
}