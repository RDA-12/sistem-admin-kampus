part of 'courses_bloc.dart';

/// Event for [CoursesBloc]
sealed class CoursesEvent extends Equatable {
  const new();
}

/// Request to subscribe to courses changes
class CoursesSubscriptionRequested extends CoursesEvent {
  /// Creates new [CoursesSubscriptionRequested]
  const new();

  @override
  List<Object?> get props => [];
}
