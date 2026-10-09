import 'package:drift/drift.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/domain/domain.dart';

/// Drift database model for [Faculty]
@DataClassName('FacultyDb')
class FacultiesDrift extends Table with AppClockMixin {
  @override
  String? get tableName => 'faculties';

  /// ID of the faculty
  TextColumn get id => text()();

  /// Name of the faculty
  TextColumn get name => text().unique()();

  /// When this faculty created
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  /// When the last time this faculty updated
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

/// Helper to converts [FacultyDb] to [Faculty]
extension ToDomainX on FacultyDb {
  /// Returns [Faculty] of this [FacultyDb]
  Faculty toDomain() => Faculty(id: id, name: name);
}

/// Helper to converts [UpdateFacultyParams] to [FacultiesDriftCompanion]
extension ToCompanionX on UpdateFacultyParams {
  /// Returns [FacultiesDriftCompanion] of this [UpdateFacultyParams]
  FacultiesDriftCompanion toCompanion() => FacultiesDriftCompanion(
    name: name == null ? const Value.absent() : Value(name!),
  );
}
