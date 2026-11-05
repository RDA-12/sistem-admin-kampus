import 'package:drift/drift.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/lecturer/domain/filters/lecturer_filter.dart';

/// Extension to apply [LecturerFilter] to Drift select statement
extension LecturerFilterX on LecturerFilter {
  /// Applies this filter to [query]
  SimpleSelectStatement<$LecturersDriftTable, LecturerDb> apply(
    SimpleSelectStatement<$LecturersDriftTable, LecturerDb> query,
  ) {
    if (programId != null) {
      query.where((tbl) => tbl.programId.equals(programId!));
    }
    return query;
  }
}
