part of 'program_detail_bloc.dart';

/// Events for [ProgramDetailBloc]
sealed class ProgramDetailEvent extends Equatable {
  /// Creates new [ProgramDetailEvent]
  const new();

  @override
  List<Object> get props => [];
}

/// Event to subscribe to [Program] data changes
class ProgramDetailSubscriptionRequested extends ProgramDetailEvent {
  /// Creates new [ProgramDetailSubscriptionRequested]
  const new({required this.id});

  /// ID of the [Program] that will be loaded
  final String id;

  @override
  List<Object> get props => [id];
}
