//  Created by smlu on 21/01/2020.
//  Copyright © 2020 ZeroPass. All rights reserved.
import 'package:flutter_test/flutter_test.dart';

import '../../lib/dmrtd/extension/datetime_apis.dart';
import '../../lib/dmrtd/extension/string_apis.dart';

void main() {
  group('Date YYMMDD format test', () {
    test('Converting DateTime to YYMMDD format string', () {
      expect( DateTime(1989, 11, 9).formatYYMMDD() , '891109' );
      expect( DateTime(1976, 05, 01).formatYYMMDD(), '760501' );
      expect( DateTime(2000, 02, 15).formatYYMMDD(), '000215' );
      expect( DateTime(2006, 08, 30).formatYYMMDD(), '060830' );
      expect( DateTime(2011, 11, 11).formatYYMMDD(), '111111' );
      expect( DateTime(2012, 12, 12).formatYYMMDD(), '121212' );
    });

    test('Converting DateTime to YYMMDD format string', () {
      expect( '891109'.parseDateYYMMDD() , DateTime(1989, 11, 9)  );
      expect( '760501'.parseDateYYMMDD() , DateTime(1976, 05, 01) );
      expect( '000215'.parseDateYYMMDD() , DateTime(2000, 02, 15) );
      expect( '111111'.parseDateYYMMDD() , DateTime(2011, 11, 11) );
      expect( '121212'.parseDateYYMMDD() , DateTime(2012, 12, 12) );
      expect( '201212'.parseDateYYMMDD() , DateTime(2020, 12, 12) );

      final now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      expect( now.formatYYMMDD().parseDateYYMMDD() , now );

      final nextMonth = DateTime(now.year, now.month + 1, now.day);
      expect( nextMonth.formatYYMMDD().parseDateYYMMDD(), nextMonth );

      final tenFromNow  = DateTime(now.year + 10, now.month, now.day);
      expect( tenFromNow.formatYYMMDD().parseDateYYMMDD(), tenFromNow );

      // 10 years and 6 months from now should wind date back for a century.
      final tenAnd6MonthsFromNow  = DateTime(now.year + 10, now.month + 6, now.day);
      final ninetyYearsAgo         = DateTime(now.year - 90, now.month + 6, now.day);
      expect( tenAnd6MonthsFromNow.formatYYMMDD().parseDateYYMMDD(), ninetyYearsAgo ); 
    });
  });
}