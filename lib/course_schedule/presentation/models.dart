import 'package:equatable/equatable.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/course_schedule/domain/domain.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';
import 'package:sistem_admin/room/room.dart';

/// UI model for [CourseSchedule]
class CourseScheduleUI extends CourseSchedule {
  /// Creates new [CourseScheduleUI]
  const new({
    required super.id,
    required super.academicYearId,
    required super.termId,
    required super.name,
    required super.start,
    required super.duration,
    required super.cohortId,
    required super.courseId,
    required super.programId,
    required super.lecturerId,
    required super.roomId,
    required this.cohort,
    required this.course,
    required this.lecturer,
    required this.room,
  });

  /// Cohort data
  final Cohort cohort;

  /// Course data
  final Course course;

  /// Lecturer data
  final Lecturer lecturer;

  /// Room data
  final Room room;

  @override
  List<Object?> get props => [
    ...super.props,
    cohort,
    course,
    lecturer,
    room,
  ];
}

/// UI model for [CourseCalendar]
class CourseScheduleCalendarUI extends Equatable {
  /// Creates new [CourseScheduleCalendarUI]
  const new({required this.academicCalendar, required this.schedules});

  /// AcademicCalendar this course calendar part of
  final AcademicCalendar academicCalendar;

  /// Map of schedules
  ///
  /// day -> course semester -> schedules
  final Map<int, Map<int, List<CourseScheduleUI>>> schedules;

  @override
  List<Object?> get props => [academicCalendar, schedules];
}
