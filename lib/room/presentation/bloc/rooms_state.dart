part of 'rooms_bloc.dart';

/// State of [RoomsBloc]
sealed class RoomsState extends Equatable {
  const new();
}

/// Initial state of [RoomsBloc]
final class RoomsInitial extends RoomsState {
  /// Creates new [RoomsInitial]
  const new();

  @override
  List<Object?> get props => [];
}

/// State when loading rooms
final class LoadingRooms extends RoomsState {
  /// Creates new [LoadingRooms]
  const new();

  @override
  List<Object?> get props => [];
}

/// State when rooms loaded
final class RoomsLoaded extends RoomsState {
  /// Creates new [RoomsLoaded]
  const new(this.data);

  /// Loaded rooms data
  final List<RoomUI> data;

  @override
  List<Object?> get props => [data];
}

/// State when failed loading rooms
final class RoomsFailure extends RoomsState {
  /// Creates new [RoomsFailure]
  const new(this.exception);

  /// Exception caused failure
  final AppException exception;

  @override
  List<Object?> get props => [exception];
}
