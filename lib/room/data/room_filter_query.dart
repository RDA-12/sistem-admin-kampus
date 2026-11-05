import 'package:drift/drift.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/room/domain/filters/room_filter.dart';

/// Extension to apply [RoomFilter] to Drift select statement
extension RoomFilterX on RoomFilter {
  /// Applies this filter to [query]
  SimpleSelectStatement<$RoomsDriftTable, RoomDb> apply(
    SimpleSelectStatement<$RoomsDriftTable, RoomDb> query,
  ) {
    if (facultyId != null) {
      query.where((tbl) => tbl.facultyId.equals(facultyId!));
    }
    return query;
  }
}
