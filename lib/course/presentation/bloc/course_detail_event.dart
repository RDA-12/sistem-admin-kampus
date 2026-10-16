part of 'course_detail_bloc.dart';

/// Events for [CourseDetailBloc]
sealed class CourseDetailEvent extends Equatable {
  /// Creates new [CourseDetailEvent]
  const new();

  @override
  List<Object> get props => [];
}

/// Event to subscribe to [Course] data changes
class CourseDetailSubscriptionRequested extends CourseDetailEvent {
  /// Creates new [CourseDetailSubscriptionRequested]
  const new({required this.id});

  /// ID of the [Course] that will be loaded
  final String id;

  @override
  List<Object> get props => [id];
}
