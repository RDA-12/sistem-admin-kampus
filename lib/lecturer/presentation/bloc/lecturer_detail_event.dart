part of 'lecturer_detail_bloc.dart';

/// Events for [LecturerDetailBloc]
sealed class LecturerDetailEvent extends Equatable {
  /// Creates new [LecturerDetailEvent]
  const new();

  @override
  List<Object> get props => [];
}

/// Event to subscribe to [Lecturer] data changes
class LecturerDetailSubscriptionRequested extends LecturerDetailEvent {
  /// Creates new [LecturerDetailSubscriptionRequested]
  const new({required this.id});

  /// ID of the [Lecturer] that will be loaded
  final String id;

  @override
  List<Object> get props => [id];
}
