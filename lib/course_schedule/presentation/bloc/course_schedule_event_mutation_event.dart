part of 'course_schedule_event_mutation_bloc.dart';

/// Event for [CourseScheduleEventMutationBloc]
sealed class CourseScheduleEventMutationEvent extends Equatable {
  /// Creates new [CourseScheduleEventMutationEvent]
  const new();
}

/// Event for creating new [CourseScheduleEvent]
final class CourseScheduleEventMutationCreateRequested
    extends CourseScheduleEventMutationEvent {
  /// Creates new [CourseScheduleEventMutationCreateRequested]
  const new({
    required this.academicYearId,
    required this.name,
    required this.start,
    required this.end,
    required this.courseDetail,
    this.recurrence = const [],
  });

  /// Academic year ID for new [CourseScheduleEvent]
  final String academicYearId;

  /// Name for new [CourseScheduleEvent]
  final String name;

  /// Start date and time for new [CourseScheduleEvent]
  final EventDateTime start;

  /// End date and time for new [CourseScheduleEvent]
  final EventDateTime end;

  /// Course detail for new [CourseScheduleEvent]
  final CourseScheduleEventDetail courseDetail;

  /// Recurrence rules (RFC5545)
  final List<String> recurrence;

  @override
  List<Object?> get props => [
    academicYearId,
    name,
    start,
    end,
    courseDetail,
    recurrence,
  ];
}

/// Event for updating a [CourseScheduleEvent]
final class CourseScheduleEventMutationUpdateRequested
    extends CourseScheduleEventMutationEvent {
  /// Creates new [CourseScheduleEventMutationUpdateRequested]
  const new({
    required this.event,
    this.academicYearId,
    this.name,
    this.start,
    this.end,
    this.courseDetail,
    this.cohortId,
    this.courseId,
    this.programId,
    this.lecturerId,
    this.roomId,
    this.recurrence,
  });

  /// [CourseScheduleEvent] that will be updated
  final CourseScheduleEvent event;

  /// New academic year ID for [event]
  final String? academicYearId;

  /// New name for [event]
  final String? name;

  /// New start date and time for [event]
  final EventDateTime? start;

  /// New end date and time for [event]
  final EventDateTime? end;

  /// New course detail for [event]
  final CourseScheduleEventDetail? courseDetail;

  /// New cohort ID for [event]
  final String? cohortId;

  /// New course ID for [event]
  final String? courseId;

  /// New program ID for [event]
  final String? programId;

  /// New lecturer ID for [event]
  final String? lecturerId;

  /// New room ID for [event]
  final String? roomId;

  /// New recurrence rules for [event]
  final List<String>? recurrence;

  @override
  List<Object?> get props => [
    event,
    academicYearId,
    name,
    start,
    end,
    courseDetail,
    cohortId,
    courseId,
    programId,
    lecturerId,
    roomId,
    recurrence,
  ];
}

/// Event for deleting a [CourseScheduleEvent]
final class CourseScheduleEventMutationDeleteRequested
    extends CourseScheduleEventMutationEvent {
  /// Creates new [CourseScheduleEventMutationDeleteRequested]
  const new({required this.event});

  /// [CourseScheduleEvent] that will be deleted
  final CourseScheduleEvent event;

  @override
  List<Object?> get props => [event];
}
