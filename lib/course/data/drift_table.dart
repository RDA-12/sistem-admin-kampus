import 'package:drift/drift.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/domain/domain.dart';
import 'package:sistem_admin/program/data/drift_table.dart';

/// Drift database model for [Course]
@DataClassName('CourseDb')
class CoursesDrift extends Table with AppClockMixin {
  @override
  String? get tableName => 'courses';

  /// ID of the course
  TextColumn get id => text()();

  /// ID of the affiliated program
  TextColumn get programId =>
      text().references(ProgramsDrift, #id, onDelete: KeyAction.cascade)();

  /// Code of the course
  TextColumn get code => text()();

  /// Name of the course
  TextColumn get name => text()();

  /// Semester of the course
  IntColumn get semester => integer()();

  /// Weight / credit (SKS) of the course
  IntColumn get credit => integer()();

  /// When this course created
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  /// When the last time this course updated
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  List<Set<Column>>? get uniqueKeys => [
    {programId, code},
  ];
}

/// Helper to convert [CourseDb] to [Course]
extension ToDomainX on CourseDb {
  /// Returns [Course] of this [CourseDb]
  Course toDomain() => Course(
    id: id,
    programId: programId,
    code: code,
    name: name,
    semester: semester,
    credit: credit,
  );
}

/// Helper to convert [UpdateCourseParams] to [CoursesDriftCompanion]
extension ToCompanionX on UpdateCourseParams {
  /// Returns [CoursesDriftCompanion] of this [UpdateCourseParams]
  CoursesDriftCompanion toCompanion() => CoursesDriftCompanion(
    code: code == null ? const Value.absent() : Value(code!),
    name: name == null ? const Value.absent() : Value(name!),
    semester: semester == null ? const Value.absent() : Value(semester!),
    credit: credit == null ? const Value.absent() : Value(credit!),
    programId: programId == null ? const Value.absent() : Value(programId!),
  );
}
