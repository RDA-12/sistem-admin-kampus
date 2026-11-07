import 'package:intl/intl.dart';

/// Format [DateTime] into 'd MMMM yyyy' string
///
/// Example:
/// ```dart
/// final date = DateTime(2026,12,1);
/// final formatted = dateFormatter.format(date);
/// print(formatted); // 1 Desember 2026
/// ```
final dateFormatter = DateFormat('d MMMM yyyy', 'id_ID');

/// Format [DateTime] into `HH:mm` string
///
/// Example:
/// ```dart
/// final date = DateTime(2026,12,1,7,0);
/// final formatted = timeFormatter.format(date);
/// print(formatted); // 07:00
/// ```
final timeFormatter = DateFormat('HH:mm', 'id_ID');

/// Provides helper function to formatting [DateTime]
extension DateTimeFormatterX on DateTime {
  /// Converts [DateTime] into 'd MMMM yyyy'
  ///
  /// Example:
  /// - DateTime(2026,9,12).dateFormat() => 12 September 2026
  String dateFormat() => dateFormatter.format(this);

  /// Converts [DateTime] into `HH:mm`
  ///
  /// Example:
  /// - DateTime(2026,9,12,7,0).timeFormat() => 07:00
  String timeFormat() => timeFormatter.format(this);
}
