import 'package:clock/clock.dart';

/// Helpers to get current [DateTime]
mixin class AppClockMixin {
  /// Return current [DateTime]
  DateTime getCurrentDateTime() => clock.now();
}
