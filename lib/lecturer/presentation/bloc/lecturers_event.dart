part of 'lecturers_bloc.dart';

/// Event for [LecturersBloc]
sealed class LecturersEvent extends Equatable {
  /// Creates new [LecturersEvent]
  const new();

  @override
  List<Object> get props => [];
}

/// Event to subscribe to lecturers data changes
final class LecturersSubscriptionRequested extends LecturersEvent {
  /// Creates new [LecturersSubscriptionRequested]
  const new();
}
