import 'package:equatable/equatable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course_schedule/domain/entities.dart';

/// Params for updating a [CourseScheduleEvent]
final class UpdateCourseScheduleEventParams extends Equatable {
  /// Creates new [UpdateCourseScheduleEventParams]
  const new(
    this.event, {
    this.academicYearId,
    this.name,
    this.start,
    this.end,
    this.recurrence,
    this.courseDetail,
    this.cohortId,
    this.courseId,
    this.programId,
    this.lecturerId,
    this.roomId,
  });

  /// Event that will be updated
  final CourseScheduleEvent event;

  /// Updated parent academic year ID
  final String? academicYearId;

  /// Updated name
  final String? name;

  /// Updated start date and time
  final EventDateTime? start;

  /// Updated end date and time
  final EventDateTime? end;

  /// Updated recurrence rules
  final List<String>? recurrence;

  /// Updated course detail
  final CourseScheduleEventDetail? courseDetail;

  /// Updated cohort ID
  final String? cohortId;

  /// Updated course ID
  final String? courseId;

  /// Updated program ID
  final String? programId;

  /// Updated lecturer ID
  final String? lecturerId;

  /// Updated room ID
  final String? roomId;

  @override
  List<Object?> get props => [
    event,
    academicYearId,
    name,
    start,
    end,
    recurrence,
    courseDetail,
    cohortId,
    courseId,
    programId,
    lecturerId,
    roomId,
  ];
}
