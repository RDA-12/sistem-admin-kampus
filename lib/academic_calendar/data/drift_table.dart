import 'package:drift/drift.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';

/// Drift database model for [AcademicYear]
@DataClassName('AcademicYearDb')
class AcademicYearsDrift extends Table with AppClockMixin {
  @override
  String? get tableName => 'academic_years';

  /// ID of the academic year
  TextColumn get id => text()();

  /// Name of the academic year
  TextColumn get name => text()();

  /// Start date of the academic year
  DateTimeColumn get startDate => dateTime()();

  /// End date of the academic year
  DateTimeColumn get endDate => dateTime()();

  /// When this academic year created
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  /// When the last time this academic year updated
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  List<Set<Column>>? get uniqueKeys => [
    {name},
  ];
}

/// Helper to convert [AcademicYearDb] to [AcademicYear]
extension AcademicYearToDomainX on AcademicYearDb {
  /// Returns [AcademicYear] of this [AcademicYearDb]
  AcademicYear toDomain() => AcademicYear(
    id: id,
    name: name,
    startDate: startDate,
    endDate: endDate,
  );
}

/// Helper to convert [UpdateAcademicYearParams] to
/// [AcademicYearsDriftCompanion]
extension AcademicYearToCompanionX on UpdateAcademicYearParams {
  /// Returns [AcademicYearsDriftCompanion] of this [UpdateAcademicYearParams]
  AcademicYearsDriftCompanion toCompanion() => AcademicYearsDriftCompanion(
    name: name == null ? const Value.absent() : Value(name!),
    startDate: startDate == null ? const Value.absent() : Value(startDate!),
    endDate: endDate == null ? const Value.absent() : Value(endDate!),
  );
}

/// Drift database model for [AcademicTerm]
@DataClassName('AcademicTermDb')
class AcademicTermsDrift extends Table with AppClockMixin {
  @override
  String? get tableName => 'academic_terms';

  /// ID of the academic term
  TextColumn get id => text()();

  /// ID of the parent academic year
  TextColumn get academicYearId => text().references(
    AcademicYearsDrift,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// Name of the academic term
  TextColumn get name => text()();

  /// Start date of the academic term
  DateTimeColumn get startDate => dateTime()();

  /// End date of the academic term
  DateTimeColumn get endDate => dateTime()();

  /// When this academic term created
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  /// When the last time this academic term updated
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  List<Set<Column>>? get uniqueKeys => [
    {academicYearId, name},
  ];
}

/// Helper to convert [AcademicTermDb] to [AcademicTerm]
extension AcademicTermToDomainX on AcademicTermDb {
  /// Returns [AcademicTerm] of this [AcademicTermDb]
  AcademicTerm toDomain() => AcademicTerm(
    id: id,
    academicYearId: academicYearId,
    name: name,
    startDate: startDate,
    endDate: endDate,
  );
}

/// Helper to convert [UpdateAcademicTermParams] to
/// [AcademicTermsDriftCompanion]
extension AcademicTermToCompanionX on UpdateAcademicTermParams {
  /// Returns [AcademicTermsDriftCompanion] of this [UpdateAcademicTermParams]
  AcademicTermsDriftCompanion toCompanion() => AcademicTermsDriftCompanion(
    academicYearId: academicYearId == null
        ? const Value.absent()
        : Value(academicYearId!),
    name: name == null ? const Value.absent() : Value(name!),
    startDate: startDate == null ? const Value.absent() : Value(startDate!),
    endDate: endDate == null ? const Value.absent() : Value(endDate!),
  );
}
