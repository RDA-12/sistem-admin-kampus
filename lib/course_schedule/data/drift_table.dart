import 'package:drift/drift.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/course_schedule/domain/domain.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';
import 'package:sistem_admin/program/program.dart';
import 'package:sistem_admin/room/room.dart';

/// Drift database model for [CourseScheduleEventDetail]
@DataClassName('CourseScheduleEventDetailDb')
class CourseScheduleEventDetailsDrift extends Table with AppClockMixin {
  @override
  String? get tableName => 'course_schedule_event_details';

  /// ID of the base academic calendar event
  TextColumn get eventId => text().references(
    AcademicCalendarEventsDrift,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// ID of the cohort which this event meant for
  TextColumn get cohortId => text().references(
    CohortsDrift,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// ID of the course for this event
  TextColumn get courseId => text().references(
    CoursesDrift,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// ID of the program
  TextColumn get programId => text().references(
    ProgramsDrift,
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

  /// When this course schedule detail was created
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  /// When the last time this course schedule detail was updated
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  @override
  Set<Column<Object>>? get primaryKey => {eventId};
}

/// Helper to convert [CourseScheduleEventDetailDb] to
/// [CourseScheduleEventDetail]
extension CourseScheduleEventDetailToDomainX on CourseScheduleEventDetailDb {
  /// Returns [CourseScheduleEventDetail] of this [CourseScheduleEventDetailDb]
  CourseScheduleEventDetail toDomain() => CourseScheduleEventDetail(
    cohortId: cohortId,
    courseId: courseId,
    programId: programId,
    lecturerId: lecturerId,
    roomId: roomId,
  );
}

/// Helper to convert [AcademicCalendarEventDb] and
/// [CourseScheduleEventDetailDb] to [CourseScheduleEvent]
extension CourseScheduleEventFromDbX on AcademicCalendarEventDb {
  /// Returns [CourseScheduleEvent] constructed from this
  /// [AcademicCalendarEventDb] and [detailDb]
  CourseScheduleEvent toCourseScheduleDomain(
    CourseScheduleEventDetailDb detailDb,
  ) => CourseScheduleEvent(
    id: id,
    academicYearId: academicYearId,
    name: name,
    start: EventDateTime(
      date: startDate,
      time: Time(hour: startHour, minute: startMinute),
    ),
    end: EventDateTime(
      date: endDate,
      time: Time(hour: endHour, minute: endMinute),
    ),
    courseDetail: detailDb.toDomain(),
  );
}

/// Helper to convert [UpdateCourseScheduleEventParams] to Drift companions
extension CourseScheduleEventToCompanionX on UpdateCourseScheduleEventParams {
  /// Returns [CourseScheduleEventDetailsDriftCompanion] of this
  /// [UpdateCourseScheduleEventParams]
  CourseScheduleEventDetailsDriftCompanion toDetailCompanion() {
    final detail = courseDetail;
    return CourseScheduleEventDetailsDriftCompanion(
      cohortId: detail != null
          ? Value(detail.cohortId)
          : cohortId == null
          ? const Value.absent()
          : Value(cohortId!),
      courseId: detail != null
          ? Value(detail.courseId)
          : courseId == null
          ? const Value.absent()
          : Value(courseId!),
      programId: detail != null
          ? Value(detail.programId)
          : programId == null
          ? const Value.absent()
          : Value(programId!),
      lecturerId: detail != null
          ? Value(detail.lecturerId)
          : lecturerId == null
          ? const Value.absent()
          : Value(lecturerId!),
      roomId: detail != null
          ? Value(detail.roomId)
          : roomId == null
          ? const Value.absent()
          : Value(roomId!),
    );
  }

  /// Returns [AcademicCalendarEventsDriftCompanion] of this
  /// [UpdateCourseScheduleEventParams]
  AcademicCalendarEventsDriftCompanion toBaseEventCompanion() =>
      AcademicCalendarEventsDriftCompanion(
        academicYearId: academicYearId == null
            ? const Value.absent()
            : Value(academicYearId!),
        name: name == null ? const Value.absent() : Value(name!),
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
