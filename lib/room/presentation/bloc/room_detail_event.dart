part of 'room_detail_bloc.dart';

/// Events for [RoomDetailBloc]
sealed class RoomDetailEvent extends Equatable {
  /// Creates new [RoomDetailEvent]
  const new();

  @override
  List<Object> get props => [];
}

/// Event to subscribe to [Room] data changes
class RoomDetailSubscriptionRequested extends RoomDetailEvent {
  /// Creates new [RoomDetailSubscriptionRequested]
  const new({required this.id});

  /// ID of the [Room] that will be loaded
  final String id;

  @override
  List<Object> get props => [id];
}
