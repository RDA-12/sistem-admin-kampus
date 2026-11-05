part of 'course_schedules_bloc.dart';

/// States for [CourseSchedulesBloc]
sealed class CourseSchedulesState extends Equatable {
  /// Creates new [CourseSchedulesState]
  const new();

  @override
  List<Object> get props => [];
}

/// Initial state
final class CourseSchedulesInitial extends CourseSchedulesState {
  /// Creates new [CourseSchedulesInitial]
  const new();
}

/// Loading schedules state
class CourseSchedulesLoadData extends CourseSchedulesState {
  /// Creates new [CourseSchedulesLoadData]
  const new();
}

/// Loading schedules state
class CourseSchedulesLoaded extends CourseSchedulesState {
  /// Creates new [CourseSchedulesLoaded]
  const new(this.calendar);

  /// Calendar data to be showed to user
  final CourseScheduleCalendarUI calendar;

  @override
  List<Object> get props => [calendar];
}

/// Loading schedules state
class CourseSchedulesLoadFailed extends CourseSchedulesState {
  /// Creates new [CourseSchedulesLoadFailed]
  const new(this.exception);

  /// Exception thrown
  final AppException exception;

  @override
  List<Object> get props => [exception];
}
