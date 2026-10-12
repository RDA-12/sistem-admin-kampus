import 'package:drift/drift.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/data/drift_table.dart';
import 'package:sistem_admin/program/domain/domain.dart';

/// Drift database model for [Program]
@DataClassName('ProgramDb')
class ProgramsDrift extends Table with AppClockMixin {
  @override
  String? get tableName => 'programs';

  /// ID of the program
  TextColumn get id => text()();

  /// ID of the parent faculty
  TextColumn get facultyId =>
      text().references(FacultiesDrift, #id, onDelete: KeyAction.cascade)();

  /// Name of the program
  TextColumn get name => text()();

  /// When this program created
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  /// When the last time this program updated
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  List<Set<Column>>? get uniqueKeys => [
    {facultyId, name},
  ];
}

/// Helper to convert [ProgramDb] to [Program]
extension ToDomainX on ProgramDb {
  /// Returns [Program] of this [ProgramDb]
  Program toDomain() => Program(
    id: id,
    facultyId: facultyId,
    name: name,
  );
}

/// Helper to convert [UpdateProgramParams] to [ProgramsDriftCompanion]
extension ToCompanionX on UpdateProgramParams {
  /// Returns [ProgramsDriftCompanion] of this [UpdateProgramParams]
  ProgramsDriftCompanion toCompanion() => ProgramsDriftCompanion(
    name: name == null ? const Value.absent() : Value(name!),
  );
}
