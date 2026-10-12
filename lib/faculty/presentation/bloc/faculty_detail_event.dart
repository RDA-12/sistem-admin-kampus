part of 'faculty_detail_bloc.dart';

/// Events for [FacultyDetailBloc]
sealed class FacultyDetailEvent extends Equatable {
  /// Creates new [FacultyDetailEvent]
  const new();

  @override
  List<Object> get props => [];
}

/// Event to subscribe to [Faculty] data chages
class FacultyDetailSubscriptionRequested extends FacultyDetailEvent {
  /// Creates new [FacultyDetailSubscriptionRequested]
  const new({required this.id});

  /// ID of the [Faculty] that will be loaded
  final String id;

  @override
  List<Object> get props => [id];
}
