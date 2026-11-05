import 'package:drift/drift.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/program/domain/filters/program_filter.dart';

/// Extension to apply [ProgramFilter] to Drift select statement
extension ProgramFilterX on ProgramFilter {
  /// Applies this filter to [query]
  SimpleSelectStatement<$ProgramsDriftTable, ProgramDb> apply(
    SimpleSelectStatement<$ProgramsDriftTable, ProgramDb> query,
  ) {
    if (facultyId != null) {
      query.where((tbl) => tbl.facultyId.equals(facultyId!));
    }
    return query;
  }
}
