import 'package:drift/drift.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/domain/filters/course_filter.dart';

/// Extension to apply [CourseFilter] to Drift select statement
extension CourseFilterX on CourseFilter {
  /// Applies this filter to [query]
  SimpleSelectStatement<$CoursesDriftTable, CourseDb> apply(
    SimpleSelectStatement<$CoursesDriftTable, CourseDb> query,
  ) {
    if (programId != null) {
      query.where((tbl) => tbl.programId.equals(programId!));
    }
    return query;
  }
}
