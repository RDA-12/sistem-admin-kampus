part of 'room_mutation_bloc.dart';

/// Possible types of room mutation
enum RoomMutationType {
  /// Create type
  create,

  /// Update type
  update,

  /// Delete type
  delete,
}

/// Notice data for [RoomMutationState]
///
/// Typically used to shows dialog/toast on UI
sealed class RoomMutationNotice extends Equatable {
  const new();
}

/// Notice when a [Room] has been updated from [before] to [after]
final class RoomUpdatedNotice extends RoomMutationNotice {
  /// Creates new [RoomUpdatedNotice]
  ///
  /// A [Room] has been updated from [before] to [after]
  const new({required this.before, required this.after});

  /// [Room] data before update
  final Room before;

  /// [Room] data after update
  final Room after;

  @override
  List<Object?> get props => [before, after];
}

/// Notice when a [Room] has been deleted
final class RoomDeletedNotice extends RoomMutationNotice {
  /// Creates new [RoomDeletedNotice] for [deleted]
  const new(this.deleted);

  /// Deleted [Room]
  final Room deleted;

  @override
  List<Object?> get props => [deleted];
}

/// Notice when a [Room] has been created
final class RoomCreatedNotice extends RoomMutationNotice {
  /// Creates new [RoomCreatedNotice] for [created]
  const new(this.created);

  /// Created [Room]
  final Room created;

  @override
  List<Object?> get props => [created];
}

/// Notice when mutation process failed
final class RoomMutationFailedNotice extends RoomMutationNotice {
  /// Creates new [RoomMutationFailedNotice] for [type] and [room]
  const new({
    required this.exception,
    required this.type,
    required this.room,
  });

  /// Type of failed mutation
  final RoomMutationType type;

  /// Room that included
  ///
  /// It will be null when [type] is [RoomMutationType.create]
  final Room? room;

  /// Exception thrown by failed mutation
  final AppException exception;

  @override
  List<Object?> get props => [type, room, exception];
}

/// State for [RoomMutationBloc]
class RoomMutationState extends Equatable {
  /// Creates new [RoomMutationState]
  const new({
    this.isCreating = false,
    this.notice,
    this.deletingIds = const {},
    this.updatingIds = const {},
  });

  /// Notice for newly completed mutation process
  final RoomMutationNotice? notice;

  /// List of [Room] ID for delete
  final Set<String> deletingIds;

  /// List of [Room] ID for update
  final Set<String> updatingIds;

  /// Whether creating new [Room] or not
  final bool isCreating;

  /// Returns new copy based on provided data
  RoomMutationState copyWith({
    RoomMutationNotice? notice,
    Set<String>? deletingIds,
    Set<String>? updatingIds,
    bool? isCreating,
  }) {
    return RoomMutationState(
      notice: notice ?? this.notice,
      deletingIds: deletingIds ?? this.deletingIds,
      updatingIds: updatingIds ?? this.updatingIds,
      isCreating: isCreating ?? this.isCreating,
    );
  }

  @override
  List<Object?> get props => [notice, deletingIds, updatingIds, isCreating];
}
