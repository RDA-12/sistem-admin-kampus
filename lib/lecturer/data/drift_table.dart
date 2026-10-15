import 'package:drift/drift.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/lecturer/domain/domain.dart';
import 'package:sistem_admin/program/data/drift_table.dart';

/// Drift database model for [Lecturer]
@DataClassName('LecturerDb')
class LecturersDrift extends Table with AppClockMixin {
  @override
  String? get tableName => 'lecturers';

  /// ID of the lecturer
  TextColumn get id => text()();

  /// ID of the affiliated program
  TextColumn get programId =>
      text().references(ProgramsDrift, #id, onDelete: KeyAction.cascade)();

  /// Name of the lecturer
  TextColumn get name => text()();

  /// Pangkat / golongan of the lecturer
  TextColumn get pangkatGolongan => text()();

  /// When this lecturer created
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  /// When the last time this lecturer updated
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  List<Set<Column>>? get uniqueKeys => [
    {programId, name},
  ];
}

/// Helper to convert [LecturerDb] to [Lecturer]
extension ToDomainX on LecturerDb {
  /// Returns [Lecturer] of this [LecturerDb]
  Lecturer toDomain() => Lecturer(
    id: id,
    programId: programId,
    name: name,
    pangkatGolongan: pangkatGolongan,
  );
}

/// Helper to convert [UpdateLecturerParams] to [LecturersDriftCompanion]
extension ToCompanionX on UpdateLecturerParams {
  /// Returns [LecturersDriftCompanion] of this [UpdateLecturerParams]
  LecturersDriftCompanion toCompanion() => LecturersDriftCompanion(
    name: name == null ? const Value.absent() : Value(name!),
    pangkatGolongan: pangkatGolongan == null
        ? const Value.absent()
        : Value(pangkatGolongan!),
    programId: programId == null ? const Value.absent() : Value(programId!),
  );
}
