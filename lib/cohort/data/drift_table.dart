import 'package:drift/drift.dart';
import 'package:sistem_admin/cohort/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';

/// Drift database model for [Cohort]
@DataClassName('CohortDb')
class CohortsDrift extends Table with AppClockMixin {
  @override
  String? get tableName => 'cohorts';

  /// ID of the cohort
  TextColumn get id => text()();

  /// Name of the cohort
  TextColumn get name => text()();

  /// Entry year of the cohort
  IntColumn get entryYear => integer()();

  /// When this cohort created
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  /// When the last time this cohort updated
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  List<Set<Column>>? get uniqueKeys => [
    {name},
  ];
}

/// Helper to convert [CohortDb] to [Cohort]
extension CohortToDomainX on CohortDb {
  /// Returns [Cohort] of this [CohortDb]
  Cohort toDomain() => Cohort(
    id: id,
    name: name,
    entryYear: entryYear,
  );
}

/// Helper to convert [UpdateCohortParams] to [CohortsDriftCompanion]
extension CohortToCompanionX on UpdateCohortParams {
  /// Returns [CohortsDriftCompanion] of this [UpdateCohortParams]
  CohortsDriftCompanion toCompanion() => CohortsDriftCompanion(
    name: name == null ? const Value.absent() : Value(name!),
    entryYear: entryYear == null ? const Value.absent() : Value(entryYear!),
  );
}
