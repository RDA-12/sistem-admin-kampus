part of 'rooms_bloc.dart';

/// Event for [RoomsBloc]
sealed class RoomsEvent extends Equatable {
  const new();
}

/// Request to subscribe to rooms changes
class RoomsSubscriptionRequested extends RoomsEvent {
  /// Creates new [RoomsSubscriptionRequested]
  const new();

  @override
  List<Object?> get props => [];
}
