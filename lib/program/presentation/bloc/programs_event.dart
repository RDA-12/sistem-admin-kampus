part of 'programs_bloc.dart';

/// Event for [ProgramsBloc]
sealed class ProgramsEvent extends Equatable {
  /// Creates new [ProgramsEvent]
  const new();

  @override
  List<Object> get props => [];
}

/// Event to subscribe to programs data changes
final class ProgramsSubscriptionRequested extends ProgramsEvent {
  /// Creates new [ProgramsSubscriptionRequested]
  const new();
}
