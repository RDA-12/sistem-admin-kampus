part of 'room_detail_bloc.dart';

/// State for [RoomDetailBloc]
sealed class RoomDetailState extends Equatable {
  /// Creates new [RoomDetailState]
  const new();

  @override
  List<Object> get props => [];
}

/// Initial state for [RoomDetailBloc]
final class RoomDetailInitial extends RoomDetailState {
  /// Creates new [RoomDetailInitial]
  const new();
}

/// State when room detail is loading
final class LoadingRoomDetail extends RoomDetailState {
  /// Creates new [LoadingRoomDetail]
  const new();
}

/// State when room detail is loaded
final class RoomDetailLoaded extends RoomDetailState {
  /// Creates new [RoomDetailLoaded]
  const new({required this.room});

  /// Loaded [RoomUI] data
  final RoomUI room;

  @override
  List<Object> get props => [room];
}

/// State when room detail data failed to load
final class RoomDetailLoadFailed extends RoomDetailState {
  /// Creates new [RoomDetailLoadFailed]
  const new({required this.exception});

  /// Exception thrown when room detail failed to load
  final AppException exception;

  @override
  List<Object> get props => [exception];
}
