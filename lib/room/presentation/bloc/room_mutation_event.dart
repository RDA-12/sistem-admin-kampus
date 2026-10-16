part of 'room_mutation_bloc.dart';

/// Event for [RoomMutationBloc]
sealed class RoomMutationEvent extends Equatable {
  /// Creates new [RoomMutationEvent]
  const new();
}

/// Event for updating a [Room]
final class RoomMutationUpdateRequested extends RoomMutationEvent {
  /// Creates new [RoomMutationUpdateRequested]
  const new({
    required this.room,
    this.name,
    this.facultyId,
  });

  /// [Room] that will be updated
  final Room room;

  /// New name for [room]
  final String? name;

  /// New faculty ID for [room]
  final String? facultyId;

  @override
  List<Object?> get props => [room, name, facultyId];
}

/// Event for creating new [Room]
final class RoomMutationCreateRequested extends RoomMutationEvent {
  /// Creates new [RoomMutationCreateRequested]
  const new({
    required this.facultyId,
    required this.name,
  });

  /// ID of the parent faculty
  final String facultyId;

  /// Name for new [Room]
  final String name;

  @override
  List<Object?> get props => [facultyId, name];
}

/// Event for deleting a [Room]
final class RoomMutationDeleteRequested extends RoomMutationEvent {
  /// Creates new [RoomMutationDeleteRequested]
  const new({required this.room});

  /// [Room] that will be deleted
  final Room room;

  @override
  List<Object?> get props => [room];
}
