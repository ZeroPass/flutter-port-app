//  Copyright © 2020 ZeroPass. All rights reserved.
import 'package:logging/logging.dart';

extension LogAlias on Logger {
    /// Log message at level [Level.FINEST].
  void trace(message, [Object error, StackTrace stackTrace]) =>
    log(Level.FINEST, message, error, stackTrace);

  /// Log message at level [Level.FINER].
  void verbose(message, [Object error, StackTrace stackTrace]) =>
    log(Level.FINER, message, error, stackTrace);

  /// Log message at level [Level.FINE].
  void debug(message, [Object error, StackTrace stackTrace]) =>
    log(Level.FINE, message, error, stackTrace);

  /// Log message at level [Level.SEVERE].
  void error(message, [Object error, StackTrace stackTrace]) =>
    log(Level.SEVERE, message, error, stackTrace);
}