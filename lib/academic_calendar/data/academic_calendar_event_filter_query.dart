import 'package:drift/drift.dart';
import 'package:sistem_admin/academic_calendar/domain/filters/academic_calendar_event_filter.dart';
import 'package:sistem_admin/common/common.dart';

/// Extension to apply [AcademicCalendarEventFilter] to Drift select statement
extension AcademicCalendarEventFilterX on AcademicCalendarEventFilter {
  /// Applies this filter to [query]
  SimpleSelectStatement<
    $AcademicCalendarEventsDriftTable,
    AcademicCalendarEventDb
  >
  apply(
    SimpleSelectStatement<
      $AcademicCalendarEventsDriftTable,
      AcademicCalendarEventDb
    >
    query,
  ) {
    if (academicYearId != null) {
      query.where((tbl) => tbl.academicYearId.equals(academicYearId!));
    }
    return query;
  }
}
