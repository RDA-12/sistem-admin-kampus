import 'package:drift/drift.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course_schedule/domain/filters/course_schedule_filter.dart';

/// Extension to apply [CourseScheduleFilter] to Drift select statement
extension CourseScheduleFilterX on CourseScheduleFilter {
  /// Applies this filter to [query]
  SimpleSelectStatement<$CourseSchedulesDriftTable, CourseScheduleDb> apply(
    SimpleSelectStatement<$CourseSchedulesDriftTable, CourseScheduleDb> query,
  ) {
    if (academicYearId != null) {
      query.where((tbl) => tbl.academicYearId.equals(academicYearId!));
    }
    if (cohortId != null) {
      query.where((tbl) => tbl.cohortId.equals(cohortId!));
    }
    if (termId != null) {
      query.where((tbl) => tbl.termId.equals(termId!));
    }
    if (programId != null) {
      query.where((tbl) => tbl.programId.equals(programId!));
    }
    return query;
  }
}
