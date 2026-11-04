part of 'course_schedule_mutation_bloc.dart';

/// Event for [CourseScheduleMutationBloc]
sealed class CourseScheduleMutationEvent extends Equatable {
  /// Creates new [CourseScheduleMutationEvent]
  const new();
}

/// Event for creating new [CourseSchedule]
final class CourseScheduleMutationCreateRequested
    extends CourseScheduleMutationEvent {
  /// Creates new [CourseScheduleMutationCreateRequested]
  const new({
    required this.academicYearId,
    required this.termId,
    required this.programId,
    required this.name,
    required this.start,
    required this.duration,
    required this.cohortId,
    required this.courseId,
    required this.lecturerId,
    required this.roomId,
  });

  /// Academic year ID for new [CourseSchedule]
  final String academicYearId;

  /// Term ID for new [CourseSchedule]
  final String termId;

  /// Program ID for new [CourseSchedule]
  final String programId;

  /// Name for new [CourseSchedule]
  final String name;

  /// Start date and time for new [CourseSchedule]
  final DateTime start;

  /// Duration for new [CourseSchedule]
  final Duration duration;

  /// Cohort ID for new [CourseSchedule]
  final String cohortId;

  /// Course ID for new [CourseSchedule]
  final String courseId;

  /// Lecturer ID for new [CourseSchedule]
  final String lecturerId;

  /// Room ID for new [CourseSchedule]
  final String roomId;

  @override
  List<Object?> get props => [
    academicYearId,
    termId,
    programId,
    name,
    start,
    duration,
    cohortId,
    courseId,
    lecturerId,
    roomId,
  ];
}

/// Event for updating a [CourseSchedule]
final class CourseScheduleMutationUpdateRequested
    extends CourseScheduleMutationEvent {
  /// Creates new [CourseScheduleMutationUpdateRequested]
  const new({
    required this.courseSchedule,
    this.academicYearId,
    this.termId,
    this.programId,
    this.name,
    this.start,
    this.duration,
    this.cohortId,
    this.courseId,
    this.lecturerId,
    this.roomId,
  });

  /// [CourseSchedule] that will be updated
  final CourseSchedule courseSchedule;

  /// New academic year ID for [courseSchedule]
  final String? academicYearId;

  /// New term ID for [courseSchedule]
  final String? termId;

  /// New program ID for [courseSchedule]
  final String? programId;

  /// New name for [courseSchedule]
  final String? name;

  /// New start date and time for [courseSchedule]
  final DateTime? start;

  /// New duration for [courseSchedule]
  final Duration? duration;

  /// New cohort ID for [courseSchedule]
  final String? cohortId;

  /// New course ID for [courseSchedule]
  final String? courseId;

  /// New lecturer ID for [courseSchedule]
  final String? lecturerId;

  /// New room ID for [courseSchedule]
  final String? roomId;

  @override
  List<Object?> get props => [
    courseSchedule,
    academicYearId,
    termId,
    programId,
    name,
    start,
    duration,
    cohortId,
    courseId,
    lecturerId,
    roomId,
  ];
}

/// Event for deleting a [CourseSchedule]
final class CourseScheduleMutationDeleteRequested
    extends CourseScheduleMutationEvent {
  /// Creates new [CourseScheduleMutationDeleteRequested]
  const new({required this.courseSchedule});

  /// [CourseSchedule] that will be deleted
  final CourseSchedule courseSchedule;

  @override
  List<Object?> get props => [courseSchedule];
}
