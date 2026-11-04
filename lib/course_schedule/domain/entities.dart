import 'package:equatable/equatable.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/core/core.dart';

/// Representing single day course schedule
class CourseSchedule extends Equatable {
  /// Creates new [CourseSchedule]
  const new({
    required this.id,
    required this.academicYearId,
    required this.termId,
    required this.name,
    required this.start,
    required this.duration,
    required this.cohortId,
    required this.courseId,
    required this.programId,
    required this.lecturerId,
    required this.roomId,
  });

  /// ID of the course schedule
  final String id;

  /// Academic year this schedule belong to
  final String academicYearId;

  /// Term this schedule belong to
  final String termId;

  /// ID of the program
  final String programId;

  /// Name of the course schedule
  final String name;

  /// When the schedule start, including its time
  final DateTime start;

  /// Duration of this course schedule
  final Duration duration;

  /// ID of the cohort which this course schedule is meant for
  final String cohortId;

  /// ID of the course for this course schedule
  final String courseId;

  /// ID of the lecturer
  final String lecturerId;

  /// ID of the room
  final String roomId;

  /// Returns list of overlapped things between this and new schedule
  List<String> overlaps({
    required DateTime start,
    required String cohortId,
    required String courseId,
    required String lecturerId,
    required String roomId,
  }) {
    final end = this.start.add(duration);
    final timeOverlapped =
        (start.isAtSameMomentAs(this.start) || start.isAfter(this.start)) &&
        start.isBefore(end);
    if (!timeOverlapped) return [];
    final overlapped = <String>[];
    if (this.roomId == roomId) overlapped.add('ruangan');
    if (this.courseId == courseId) overlapped.add('mata kuliah');
    if (this.lecturerId == lecturerId) overlapped.add('dosen');
    if (this.cohortId == cohortId) overlapped.add('angkatan');
    return overlapped;
  }

  @override
  List<Object?> get props => [
    id,
    academicYearId,
    termId,
    name,
    start,
    duration,
    cohortId,
    courseId,
    programId,
    lecturerId,
    roomId,
  ];
}

/// Representing course schedules in a calendar
class CourseCalendar extends Equatable {
  /// Creates new [CourseCalendar]
  const new({
    required this.academicCalendar,
    required this.schedules,
  });

  /// Academic calendar this course calendar part of
  final AcademicCalendar academicCalendar;

  /// List of course schedule included in this calendar
  final List<CourseSchedule> schedules;

  /// Returns success when the new schedule can be added
  AppResult<Null> canAddSchedule({
    required DateTime start,
    required String cohortId,
    required String courseId,
    required String lecturerId,
    required String roomId,
  }) {
    final collisionDetails = <CourseScheduleCollisionDetail>[];
    for (final schedule in schedules) {
      final isOverlapped = schedule
          .overlaps(
            start: start,
            cohortId: cohortId,
            courseId: courseId,
            lecturerId: lecturerId,
            roomId: roomId,
          )
          .isNotEmpty;
      if (isOverlapped) {
        collisionDetails.add(
          CourseScheduleCollisionDetail(
            start: schedule.start,
            duration: schedule.duration,
            cohortId: schedule.cohortId,
            courseId: schedule.courseId,
            lecturerId: schedule.lecturerId,
            roomId: schedule.roomId,
          ),
        );
      }
    }
    if (collisionDetails.isNotEmpty) {
      return AppResult.failure(
        CourseScheduleCollisionException(details: collisionDetails),
      );
    }
    return AppResult.success(null);
  }

  /// Returns success when the schedule can be updated to new schedule
  AppResult<Null> canUpdateSchedule({
    required String scheduleId,
    required DateTime start,
    required String cohortId,
    required String courseId,
    required String lecturerId,
    required String roomId,
  }) {
    final collisionDetails = <CourseScheduleCollisionDetail>[];
    for (final schedule in schedules) {
      if (schedule.id == scheduleId) continue;
      final isOverlapped = schedule
          .overlaps(
            start: start,
            cohortId: cohortId,
            courseId: courseId,
            lecturerId: lecturerId,
            roomId: roomId,
          )
          .isNotEmpty;
      if (isOverlapped) {
        collisionDetails.add(
          CourseScheduleCollisionDetail(
            start: schedule.start,
            duration: schedule.duration,
            cohortId: schedule.cohortId,
            courseId: schedule.courseId,
            lecturerId: schedule.lecturerId,
            roomId: schedule.roomId,
          ),
        );
      }
    }
    if (collisionDetails.isNotEmpty) {
      return AppResult.failure(
        CourseScheduleCollisionException(details: collisionDetails),
      );
    }
    return AppResult.success(null);
  }

  @override
  List<Object?> get props => [academicCalendar, schedules];
}
