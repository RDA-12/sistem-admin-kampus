part of 'faculty_mutation_bloc.dart';

/// Possible types of faculty mutation
enum FacultyMutationType {
  /// Create type
  create,

  /// Update type
  update,

  /// Delete type
  delete,
}

/// Notice data for [FacultyMutationState]
///
/// Typically used to shows dialog/toast on UI
sealed class FacultyMutationNotice extends Equatable {
  const new();
}

/// Notice when a [Faculty] has been updated from [before] to [after]
final class FacultyUpdatedNotice extends FacultyMutationNotice {
  /// Creates new [FacultyUpdatedNotice]
  ///
  /// A [Faculty] has been updated from [before] to [after]
  const new({required this.before, required this.after});

  /// [Faculty] data before update
  final Faculty before;

  /// [Faculty] data after update
  final Faculty after;

  @override
  List<Object?> get props => [before, after];
}

/// Notice when a [Faculty] has been deleted
final class FacultyDeletedNotice extends FacultyMutationNotice {
  /// Creates new [FacultyDeletedNotice] for [deleted]
  const new(this.deleted);

  /// Deleted [Faculty]
  final Faculty deleted;

  @override
  List<Object?> get props => [deleted];
}

/// Notice when a [Faculty] has been created
final class FacultyCreatedNotice extends FacultyMutationNotice {
  /// Creates new [FacultyCreatedNotice] for [created]
  const new(this.created);

  /// Created [Faculty]
  final Faculty created;

  @override
  List<Object?> get props => [created];
}

/// Notice when mutation process failed
final class FacultyMutationFailedNotice extends FacultyMutationNotice {
  /// Creeates new [FacultyMutationFailedNotice] for [type] and [faculty]
  const new({
    required this.exception,
    required this.type,
    required this.faculty,
  });

  /// Type of failed mutation
  final FacultyMutationType type;

  /// Faculty that included
  ///
  /// It will be null when [type] is [FacultyMutationType.create]
  final Faculty? faculty;

  /// Exception thrown by failed mutation
  final AppException exception;

  @override
  List<Object?> get props => [type, faculty, exception];
}

/// State for [FacultyMutationBloc]
class FacultyMutationState extends Equatable {
  /// Creates new [FacultyMutationState]
  const new({
    this.isCreating = false,
    this.notice,
    this.deletingIds = const {},
    this.updatingIds = const {},
  });

  /// Notice for newly completed mutation process
  final FacultyMutationNotice? notice;

  /// List of [Faculty] ID for delete
  final Set<String> deletingIds;

  /// List of [Faculty] ID for update
  final Set<String> updatingIds;

  /// Whether creating new [Faculty] or not
  final bool isCreating;

  /// Returns new copy based on provided data
  FacultyMutationState copyWith({
    FacultyMutationNotice? notice,
    Set<String>? deletingIds,
    Set<String>? updatingIds,
    bool? isCreating,
  }) {
    return FacultyMutationState(
      notice: notice ?? this.notice,
      deletingIds: deletingIds ?? this.deletingIds,
      updatingIds: updatingIds ?? this.updatingIds,
      isCreating: isCreating ?? this.isCreating,
    );
  }

  @override
  List<Object?> get props => [notice, deletingIds, updatingIds];
}
