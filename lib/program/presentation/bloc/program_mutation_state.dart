part of 'program_mutation_bloc.dart';

/// Possible types of program mutation
enum ProgramMutationType {
  /// Create type
  create,

  /// Update type
  update,

  /// Delete type
  delete,
}

/// Notice data for [ProgramMutationState]
///
/// Typically used to shows dialog/toast on UI
sealed class ProgramMutationNotice extends Equatable {
  const new();
}

/// Notice when a [Program] has been updated from [before] to [after]
final class ProgramUpdatedNotice extends ProgramMutationNotice {
  /// Creates new [ProgramUpdatedNotice]
  ///
  /// A [Program] has been updated from [before] to [after]
  const new({required this.before, required this.after});

  /// [Program] data before update
  final Program before;

  /// [Program] data after update
  final Program after;

  @override
  List<Object?> get props => [before, after];
}

/// Notice when a [Program] has been deleted
final class ProgramDeletedNotice extends ProgramMutationNotice {
  /// Creates new [ProgramDeletedNotice] for [deleted]
  const new(this.deleted);

  /// Deleted [Program]
  final Program deleted;

  @override
  List<Object?> get props => [deleted];
}

/// Notice when a [Program] has been created
final class ProgramCreatedNotice extends ProgramMutationNotice {
  /// Creates new [ProgramCreatedNotice] for [created]
  const new(this.created);

  /// Created [Program]
  final Program created;

  @override
  List<Object?> get props => [created];
}

/// Notice when mutation process failed
final class ProgramMutationFailedNotice extends ProgramMutationNotice {
  /// Creates new [ProgramMutationFailedNotice] for [type] and [program]
  const new({
    required this.exception,
    required this.type,
    required this.program,
  });

  /// Type of failed mutation
  final ProgramMutationType type;

  /// Program that included
  ///
  /// It will be null when [type] is [ProgramMutationType.create]
  final Program? program;

  /// Exception thrown by failed mutation
  final AppException exception;

  @override
  List<Object?> get props => [type, program, exception];
}

/// State for [ProgramMutationBloc]
class ProgramMutationState extends Equatable {
  /// Creates new [ProgramMutationState]
  const new({
    this.isCreating = false,
    this.notice,
    this.deletingIds = const {},
    this.updatingIds = const {},
  });

  /// Notice for newly completed mutation process
  final ProgramMutationNotice? notice;

  /// List of [Program] ID for delete
  final Set<String> deletingIds;

  /// List of [Program] ID for update
  final Set<String> updatingIds;

  /// Whether creating new [Program] or not
  final bool isCreating;

  /// Returns new copy based on provided data
  ProgramMutationState copyWith({
    ProgramMutationNotice? notice,
    Set<String>? deletingIds,
    Set<String>? updatingIds,
    bool? isCreating,
  }) {
    return ProgramMutationState(
      notice: notice ?? this.notice,
      deletingIds: deletingIds ?? this.deletingIds,
      updatingIds: updatingIds ?? this.updatingIds,
      isCreating: isCreating ?? this.isCreating,
    );
  }

  @override
  List<Object?> get props => [notice, deletingIds, updatingIds, isCreating];
}
