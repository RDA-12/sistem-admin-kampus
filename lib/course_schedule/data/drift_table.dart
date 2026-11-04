import 'package:drift/drift.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/course_schedule/domain/domain.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';
import 'package:sistem_admin/program/program.dart';
import 'package:sistem_admin/room/room.dart';

/// Drift database model for [CourseSchedule]
@DataClassName('CourseScheduleDb')
class CourseSchedulesDrift extends Table with AppClockMixin {
  @override
  String? get tableName => 'course_schedules';

  /// ID of the course schedule
  TextColumn get id => text()();

  /// ID of the academic year
  TextColumn get academicYearId => text().references(
    AcademicYearsDrift,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// ID of the academic term
  TextColumn get termId => text().references(
    AcademicTermsDrift,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// ID of the program
  TextColumn get programId => text().references(
    ProgramsDrift,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// Name of the course schedule
  TextColumn get name => text()();

  /// When the schedule start, including its time
  DateTimeColumn get start => dateTime()();

  /// Duration in minutes
  IntColumn get durationInMinutes => integer()();

  /// ID of the cohort
  TextColumn get cohortId => text().references(
    CohortsDrift,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// ID of the course
  TextColumn get courseId => text().references(
    CoursesDrift,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// ID of the lecturer
  TextColumn get lecturerId => text().references(
    LecturersDrift,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// ID of the room
  TextColumn get roomId => text().references(
    RoomsDrift,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// When this course schedule was created
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  /// When the last time this course schedule was updated
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

/// Helper to convert [CourseScheduleDb] to [CourseSchedule]
extension CourseScheduleToDomainX on CourseScheduleDb {
  /// Returns [CourseSchedule] of this [CourseScheduleDb]
  CourseSchedule toDomain() => CourseSchedule(
    id: id,
    academicYearId: academicYearId,
    termId: termId,
    programId: programId,
    name: name,
    start: start,
    duration: Duration(minutes: durationInMinutes),
    cohortId: cohortId,
    courseId: courseId,
    lecturerId: lecturerId,
    roomId: roomId,
  );
}

/// Helper to convert [UpdateCourseScheduleParams] to Drift companions
extension CourseScheduleToCompanionX on UpdateCourseScheduleParams {
  /// Returns [CourseSchedulesDriftCompanion] of this
  /// [UpdateCourseScheduleParams]
  CourseSchedulesDriftCompanion toCompanion() => CourseSchedulesDriftCompanion(
    academicYearId: academicYearId == null
        ? const Value.absent()
        : Value(academicYearId!),
    termId: termId == null ? const Value.absent() : Value(termId!),
    programId: programId == null ? const Value.absent() : Value(programId!),
    name: name == null ? const Value.absent() : Value(name!),
    start: start == null ? const Value.absent() : Value(start!),
    durationInMinutes: duration == null
        ? const Value.absent()
        : Value(duration!.inMinutes),
    cohortId: cohortId == null ? const Value.absent() : Value(cohortId!),
    courseId: courseId == null ? const Value.absent() : Value(courseId!),
    lecturerId: lecturerId == null ? const Value.absent() : Value(lecturerId!),
    roomId: roomId == null ? const Value.absent() : Value(roomId!),
  );
}
