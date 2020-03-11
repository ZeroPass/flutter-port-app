//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'dart:math';

class Utils {

  /// Returns number of bits in integer [n].
  /// [n] must be positive integer number.
  static int bitCount(final int n) {
    if(n < 0) {
      throw ArgumentError.value(n, null, "n is negative");
    }

    // calculates floor(log(2)) + 1
    // log should be log at base e (ln)
    return n == 0 ? 0 : (log(n) / log(2)).floor() + 1;
  }

  /// Returns number of bytes in integer [n].
  /// [n] must be positive integer number.
  static int byteCount(final int n) {
    return (bitCount(n) / 8).ceil();
  }
}
