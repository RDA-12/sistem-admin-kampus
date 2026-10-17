part of 'academic_term_mutation_bloc.dart';

/// Possible types of academic term mutation
enum AcademicTermMutationType {
  /// Create type
  create,

  /// Update type
  update,

  /// Delete type
  delete,
}

/// Notice data for [AcademicTermMutationState]
///
/// Typically used to shows dialog/toast on UI
sealed class AcademicTermMutationNotice extends Equatable {
  const new();
}

/// Notice when an [AcademicTerm] has been updated from [before] to [after]
final class AcademicTermUpdatedNotice extends AcademicTermMutationNotice {
  /// Creates new [AcademicTermUpdatedNotice]
  const new({required this.before, required this.after});

  /// [AcademicTerm] data before update
  final AcademicTerm before;

  /// [AcademicTerm] data after update
  final AcademicTerm after;

  @override
  List<Object?> get props => [before, after];
}

/// Notice when an [AcademicTerm] has been deleted
final class AcademicTermDeletedNotice extends AcademicTermMutationNotice {
  /// Creates new [AcademicTermDeletedNotice] for [deleted]
  const new(this.deleted);

  /// Deleted [AcademicTerm]
  final AcademicTerm deleted;

  @override
  List<Object?> get props => [deleted];
}

/// Notice when an [AcademicTerm] has been created
final class AcademicTermCreatedNotice extends AcademicTermMutationNotice {
  /// Creates new [AcademicTermCreatedNotice] for [created]
  const new(this.created);

  /// Created [AcademicTerm]
  final AcademicTerm created;

  @override
  List<Object?> get props => [created];
}

/// Notice when academic term mutation process failed
final class AcademicTermMutationFailedNotice
    extends AcademicTermMutationNotice {
  /// Creates new [AcademicTermMutationFailedNotice]
  const new({
    required this.exception,
    required this.type,
    required this.academicTerm,
  });

  /// Type of failed mutation
  final AcademicTermMutationType type;

  /// Academic term that was included
  ///
  /// It will be null when [type] is [AcademicTermMutationType.create]
  final AcademicTerm? academicTerm;

  /// Exception thrown by failed mutation
  final AppException exception;

  @override
  List<Object?> get props => [type, academicTerm, exception];
}

/// State for [AcademicTermMutationBloc]
class AcademicTermMutationState extends Equatable {
  /// Creates new [AcademicTermMutationState]
  const new({
    this.isCreating = false,
    this.notice,
    this.deletingIds = const {},
    this.updatingIds = const {},
  });

  /// Notice for newly completed mutation process
  final AcademicTermMutationNotice? notice;

  /// List of [AcademicTerm] ID for delete
  final Set<String> deletingIds;

  /// List of [AcademicTerm] ID for update
  final Set<String> updatingIds;

  /// Whether creating new [AcademicTerm] or not
  final bool isCreating;

  /// Returns new copy based on provided data
  AcademicTermMutationState copyWith({
    AcademicTermMutationNotice? notice,
    Set<String>? deletingIds,
    Set<String>? updatingIds,
    bool? isCreating,
  }) {
    return AcademicTermMutationState(
      notice: notice ?? this.notice,
      deletingIds: deletingIds ?? this.deletingIds,
      updatingIds: updatingIds ?? this.updatingIds,
      isCreating: isCreating ?? this.isCreating,
    );
  }

  @override
  List<Object?> get props => [notice, deletingIds, updatingIds, isCreating];
}
