part of 'course_schedules_bloc.dart';

/// Events for [CourseSchedulesBloc]
sealed class CourseSchedulesEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

/// Event to subscribe for calendar data changes
class CourseSchedulesSubscriptionRequested extends CourseSchedulesEvent {
  /// Creates new [CourseSchedulesSubscriptionRequested]
  const new({
    required this.academicYearId,
    required this.termId,
    required this.programId,
  });

  /// ID of academic year
  final String academicYearId;

  /// ID of term id
  ///
  /// Should be one of terms in [academicYearId]
  final String termId;

  /// ID of program
  final String programId;

  @override
  List<Object> get props => [
    academicYearId,
    termId,
    programId,
  ];
}
