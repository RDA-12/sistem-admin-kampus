import 'package:equatable/equatable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course_schedule/domain/entities.dart';

/// Params for creating a [CourseScheduleEvent]
final class CreateCourseScheduleEventParams extends Equatable {
  /// Creates new [CreateCourseScheduleEventParams]
  const new({
    required this.academicYearId,
    required this.name,
    required this.start,
    required this.end,
    required this.courseDetail,
    this.recurrence = const [],
  });

  /// ID of the parent academic year
  final String academicYearId;

  /// Name of the event
  final String name;

  /// When the event starts
  final EventDateTime start;

  /// When the event ends
  final EventDateTime end;

  /// Recurrence rules (RFC5545)
  final List<String> recurrence;

  /// Detail of course for this event
  final CourseScheduleEventDetail courseDetail;

  @override
  List<Object?> get props => [
    academicYearId,
    name,
    start,
    end,
    recurrence,
    courseDetail,
  ];
}
