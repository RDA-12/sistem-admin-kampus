part of 'cohort_mutation_bloc.dart';

/// Possible types of cohort mutation
enum CohortMutationType {
  /// Create type
  create,

  /// Update type
  update,

  /// Delete type
  delete,
}

/// Notice data for [CohortMutationState]
///
/// Typically used to show dialog/toast on UI
sealed class CohortMutationNotice extends Equatable {
  const new();
}

/// Notice when a [Cohort] has been updated from [before] to [after]
final class CohortUpdatedNotice extends CohortMutationNotice {
  /// Creates new [CohortUpdatedNotice]
  const new({required this.before, required this.after});

  /// [Cohort] data before update
  final Cohort before;

  /// [Cohort] data after update
  final Cohort after;

  @override
  List<Object?> get props => [before, after];
}

/// Notice when a [Cohort] has been deleted
final class CohortDeletedNotice extends CohortMutationNotice {
  /// Creates new [CohortDeletedNotice] for [deleted]
  const new(this.deleted);

  /// Deleted [Cohort]
  final Cohort deleted;

  @override
  List<Object?> get props => [deleted];
}

/// Notice when a [Cohort] has been created
final class CohortCreatedNotice extends CohortMutationNotice {
  /// Creates new [CohortCreatedNotice] for [created]
  const new(this.created);

  /// Created [Cohort]
  final Cohort created;

  @override
  List<Object?> get props => [created];
}

/// Notice when cohort mutation process failed
final class CohortMutationFailedNotice extends CohortMutationNotice {
  /// Creates new [CohortMutationFailedNotice]
  const new({
    required this.exception,
    required this.type,
    required this.cohort,
  });

  /// Type of failed mutation
  final CohortMutationType type;

  /// Cohort that was included
  ///
  /// It will be null when [type] is [CohortMutationType.create]
  final Cohort? cohort;

  /// Exception thrown by failed mutation
  final AppException exception;

  @override
  List<Object?> get props => [type, cohort, exception];
}

/// State for [CohortMutationBloc]
class CohortMutationState extends Equatable {
  /// Creates new [CohortMutationState]
  const new({
    this.isCreating = false,
    this.notice,
    this.deletingIds = const {},
    this.updatingIds = const {},
  });

  /// Notice for newly completed mutation process
  final CohortMutationNotice? notice;

  /// List of [Cohort] ID for delete
  final Set<String> deletingIds;

  /// List of [Cohort] ID for update
  final Set<String> updatingIds;

  /// Whether creating new [Cohort] or not
  final bool isCreating;

  /// Returns new copy based on provided data
  CohortMutationState copyWith({
    CohortMutationNotice? notice,
    Set<String>? deletingIds,
    Set<String>? updatingIds,
    bool? isCreating,
  }) {
    return CohortMutationState(
      notice: notice ?? this.notice,
      deletingIds: deletingIds ?? this.deletingIds,
      updatingIds: updatingIds ?? this.updatingIds,
      isCreating: isCreating ?? this.isCreating,
    );
  }

  @override
  List<Object?> get props => [notice, deletingIds, updatingIds, isCreating];
}
