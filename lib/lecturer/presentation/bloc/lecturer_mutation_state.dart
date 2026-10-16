part of 'lecturer_mutation_bloc.dart';

/// Possible types of lecturer mutation
enum LecturerMutationType {
  /// Create type
  create,

  /// Update type
  update,

  /// Delete type
  delete,
}

/// Notice data for [LecturerMutationState]
///
/// Typically used to shows dialog/toast on UI
sealed class LecturerMutationNotice extends Equatable {
  const new();
}

/// Notice when a [Lecturer] has been updated from [before] to [after]
final class LecturerUpdatedNotice extends LecturerMutationNotice {
  /// Creates new [LecturerUpdatedNotice]
  ///
  /// A [Lecturer] has been updated from [before] to [after]
  const new({required this.before, required this.after});

  /// [Lecturer] data before update
  final Lecturer before;

  /// [Lecturer] data after update
  final Lecturer after;

  @override
  List<Object?> get props => [before, after];
}

/// Notice when a [Lecturer] has been deleted
final class LecturerDeletedNotice extends LecturerMutationNotice {
  /// Creates new [LecturerDeletedNotice] for [deleted]
  const new(this.deleted);

  /// Deleted [Lecturer]
  final Lecturer deleted;

  @override
  List<Object?> get props => [deleted];
}

/// Notice when a [Lecturer] has been created
final class LecturerCreatedNotice extends LecturerMutationNotice {
  /// Creates new [LecturerCreatedNotice] for [created]
  const new(this.created);

  /// Created [Lecturer]
  final Lecturer created;

  @override
  List<Object?> get props => [created];
}

/// Notice when mutation process failed
final class LecturerMutationFailedNotice extends LecturerMutationNotice {
  /// Creates new [LecturerMutationFailedNotice] for [type] and [lecturer]
  const new({
    required this.exception,
    required this.type,
    required this.lecturer,
  });

  /// Type of failed mutation
  final LecturerMutationType type;

  /// Lecturer that included
  ///
  /// It will be null when [type] is [LecturerMutationType.create]
  final Lecturer? lecturer;

  /// Exception thrown by failed mutation
  final AppException exception;

  @override
  List<Object?> get props => [type, lecturer, exception];
}

/// State for [LecturerMutationBloc]
class LecturerMutationState extends Equatable {
  /// Creates new [LecturerMutationState]
  const new({
    this.isCreating = false,
    this.notice,
    this.deletingIds = const {},
    this.updatingIds = const {},
  });

  /// Notice for newly completed mutation process
  final LecturerMutationNotice? notice;

  /// List of [Lecturer] ID for delete
  final Set<String> deletingIds;

  /// List of [Lecturer] ID for update
  final Set<String> updatingIds;

  /// Whether creating new [Lecturer] or not
  final bool isCreating;

  /// Returns new copy based on provided data
  LecturerMutationState copyWith({
    LecturerMutationNotice? notice,
    Set<String>? deletingIds,
    Set<String>? updatingIds,
    bool? isCreating,
  }) {
    return LecturerMutationState(
      notice: notice ?? this.notice,
      deletingIds: deletingIds ?? this.deletingIds,
      updatingIds: updatingIds ?? this.updatingIds,
      isCreating: isCreating ?? this.isCreating,
    );
  }

  @override
  List<Object?> get props => [notice, deletingIds, updatingIds, isCreating];
}
