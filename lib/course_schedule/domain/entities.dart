import 'package:equatable/equatable.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';

/// Event for course schedule
class CourseScheduleEvent extends AcademicCalendarEvent {
  /// Creates new [CourseScheduleEvent]
  const new({
    required super.id,
    required super.academicYearId,
    required super.name,
    required super.start,
    required super.end,
    required this.courseDetail,
    super.recurrence,
  }) : super(type: .lectures);

  /// Detail of course for this event
  final CourseScheduleEventDetail courseDetail;

  @override
  List<Object?> get props => [
    ...super.props,
    courseDetail,
  ];
}

/// Detail of an event for course schedule
class CourseScheduleEventDetail extends Equatable {
  /// Creates new [CourseScheduleEventDetail]
  const new({
    required this.cohortId,
    required this.courseId,
    required this.programId,
    required this.lecturerId,
    required this.roomId,
  });

  /// ID of the cohort which this event meant for
  final String cohortId;

  /// ID of the course for this event
  final String courseId;

  /// ID of the program
  final String programId;

  /// ID of the lecturer
  final String lecturerId;

  /// ID of the room
  final String roomId;

  @override
  List<Object?> get props => [
    cohortId,
    courseId,
    programId,
    lecturerId,
    roomId,
  ];
}
