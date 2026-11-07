import 'package:collection/collection.dart';
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
  new({required this.academicCalendar, required this.schedules});

  /// AcademicCalendar this course calendar part of
  final AcademicCalendar academicCalendar;

  /// List of schedules
  final List<CourseScheduleUI> schedules;

  /// List of possible semesters the schedules has
  late final List<int> listOfSemester = schedules
      .fold(
        <int>{},
        (p, e) => p..add(e.course.semester),
      )
      .sorted((a, b) => a.compareTo(b));

  @override
  List<Object?> get props => [academicCalendar, schedules];
}
