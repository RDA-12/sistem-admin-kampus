import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';

/// Converts [List<String>] to JSON string for SQLite storage
class StringListConverter extends TypeConverter<List<String>, String> {
  /// Creates new [StringListConverter]
  const new();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    return (json.decode(fromDb) as List<dynamic>).cast<String>();
  }

  @override
  String toSql(List<String> value) => json.encode(value);
}

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

/// Drift database model for [AcademicCalendarEvent]
@DataClassName('AcademicCalendarEventDb')
class AcademicCalendarEventsDrift extends Table with AppClockMixin {
  @override
  String? get tableName => 'academic_calendar_events';

  /// ID of the academic calendar event
  TextColumn get id => text()();

  /// ID of the parent academic year
  TextColumn get academicYearId => text().references(
    AcademicYearsDrift,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// Name of the academic calendar event
  TextColumn get name => text()();

  /// Type of the academic calendar event
  TextColumn get type => textEnum<AcademicCalendarEventType>()();

  /// Start date of the academic calendar event
  DateTimeColumn get startDate => dateTime()();

  /// Start hour of the academic calendar event
  IntColumn get startHour => integer()();

  /// Start minute of the academic calendar event
  IntColumn get startMinute => integer()();

  /// End date of the academic calendar event
  DateTimeColumn get endDate => dateTime()();

  /// End hour of the academic calendar event
  IntColumn get endHour => integer()();

  /// End minute of the academic calendar event
  IntColumn get endMinute => integer()();

  /// Recurrence rules (RFC5545)
  TextColumn get recurrence =>
      text().map(const StringListConverter()).clientDefault(() => '[]')();

  /// When this academic calendar event created
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  /// When the last time this academic calendar event updated
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

/// Helper to convert [AcademicCalendarEventDb] to [AcademicCalendarEvent]
extension AcademicCalendarEventToDomainX on AcademicCalendarEventDb {
  /// Returns [AcademicCalendarEvent] of this [AcademicCalendarEventDb]
  AcademicCalendarEvent toDomain() => AcademicCalendarEvent(
    id: id,
    academicYearId: academicYearId,
    name: name,
    type: type,
    start: EventDateTime(
      date: startDate,
      time: Time(hour: startHour, minute: startMinute),
    ),
    end: EventDateTime(
      date: endDate,
      time: Time(hour: endHour, minute: endMinute),
    ),
    recurrence: recurrence,
  );
}

/// Helper to convert [UpdateAcademicCalendarEventParams] to
/// [AcademicCalendarEventsDriftCompanion]
extension AcademicCalendarEventToCompanionX
    on UpdateAcademicCalendarEventParams {
  /// Returns [AcademicCalendarEventsDriftCompanion] of this
  /// [UpdateAcademicCalendarEventParams]
  AcademicCalendarEventsDriftCompanion toCompanion() =>
      AcademicCalendarEventsDriftCompanion(
        academicYearId: academicYearId == null
            ? const Value.absent()
            : Value(academicYearId!),
        name: name == null ? const Value.absent() : Value(name!),
        type: type == null ? const Value.absent() : Value(type!),
        startDate: start == null ? const Value.absent() : Value(start!.date),
        startHour: start == null
            ? const Value.absent()
            : Value(start!.time.hour),
        startMinute: start == null
            ? const Value.absent()
            : Value(start!.time.minute),
        endDate: end == null ? const Value.absent() : Value(end!.date),
        endHour: end == null ? const Value.absent() : Value(end!.time.hour),
        endMinute: end == null ? const Value.absent() : Value(end!.time.minute),
        recurrence: recurrence == null
            ? const Value.absent()
            : Value(recurrence!),
      );
}
