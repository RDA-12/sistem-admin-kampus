import 'package:drift/drift.dart';
import 'package:sistem_admin/academic_calendar/domain/filters/academic_term_filter.dart';
import 'package:sistem_admin/common/common.dart';

/// Extension to apply [AcademicTermFilter] to Drift select statement
extension AcademicTermFilterX on AcademicTermFilter {
  /// Applies this filter to [query]
  SimpleSelectStatement<$AcademicTermsDriftTable, AcademicTermDb> apply(
    SimpleSelectStatement<$AcademicTermsDriftTable, AcademicTermDb> query,
  ) {
    if (academicYearId != null) {
      query.where((tbl) => tbl.academicYearId.equals(academicYearId!));
    }
    return query;
  }
}
