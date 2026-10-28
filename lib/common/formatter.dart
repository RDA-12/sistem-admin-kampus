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

/// Provides helper function to formatting [DateTime]
extension DateTimeFormatterX on DateTime {
  /// Returns [DateTime] into 'd MMMM yyyy'
  ///
  /// Example:
  /// - DateTime(2026,9,12).dateFormat() => 12 September 2026
  String dateFormat() => dateFormatter.format(this);
}
