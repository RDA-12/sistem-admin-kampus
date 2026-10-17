part of 'academic_year_mutation_bloc.dart';

/// Possible types of academic year mutation
enum AcademicYearMutationType {
  /// Create type
  create,

  /// Update type
  update,

  /// Delete type
  delete,
}

/// Notice data for [AcademicYearMutationState]
///
/// Typically used to shows dialog/toast on UI
sealed class AcademicYearMutationNotice extends Equatable {
  const new();
}

/// Notice when an [AcademicYear] has been updated from [before] to [after]
final class AcademicYearUpdatedNotice extends AcademicYearMutationNotice {
  /// Creates new [AcademicYearUpdatedNotice]
  const new({required this.before, required this.after});

  /// [AcademicYear] data before update
  final AcademicYear before;

  /// [AcademicYear] data after update
  final AcademicYear after;

  @override
  List<Object?> get props => [before, after];
}

/// Notice when an [AcademicYear] has been deleted
final class AcademicYearDeletedNotice extends AcademicYearMutationNotice {
  /// Creates new [AcademicYearDeletedNotice] for [deleted]
  const new(this.deleted);

  /// Deleted [AcademicYear]
  final AcademicYear deleted;

  @override
  List<Object?> get props => [deleted];
}

/// Notice when an [AcademicYear] has been created
final class AcademicYearCreatedNotice extends AcademicYearMutationNotice {
  /// Creates new [AcademicYearCreatedNotice] for [created]
  const new(this.created);

  /// Created [AcademicYear]
  final AcademicYear created;

  @override
  List<Object?> get props => [created];
}

/// Notice when academic year mutation process failed
final class AcademicYearMutationFailedNotice
    extends AcademicYearMutationNotice {
  /// Creates new [AcademicYearMutationFailedNotice]
  const new({
    required this.exception,
    required this.type,
    required this.academicYear,
  });

  /// Type of failed mutation
  final AcademicYearMutationType type;

  /// Academic year that was included
  ///
  /// It will be null when [type] is [AcademicYearMutationType.create]
  final AcademicYear? academicYear;

  /// Exception thrown by failed mutation
  final AppException exception;

  @override
  List<Object?> get props => [type, academicYear, exception];
}

/// State for [AcademicYearMutationBloc]
class AcademicYearMutationState extends Equatable {
  /// Creates new [AcademicYearMutationState]
  const new({
    this.isCreating = false,
    this.notice,
    this.deletingIds = const {},
    this.updatingIds = const {},
  });

  /// Notice for newly completed mutation process
  final AcademicYearMutationNotice? notice;

  /// List of [AcademicYear] ID for delete
  final Set<String> deletingIds;

  /// List of [AcademicYear] ID for update
  final Set<String> updatingIds;

  /// Whether creating new [AcademicYear] or not
  final bool isCreating;

  /// Returns new copy based on provided data
  AcademicYearMutationState copyWith({
    AcademicYearMutationNotice? notice,
    Set<String>? deletingIds,
    Set<String>? updatingIds,
    bool? isCreating,
  }) {
    return AcademicYearMutationState(
      notice: notice ?? this.notice,
      deletingIds: deletingIds ?? this.deletingIds,
      updatingIds: updatingIds ?? this.updatingIds,
      isCreating: isCreating ?? this.isCreating,
    );
  }

  @override
  List<Object?> get props => [notice, deletingIds, updatingIds, isCreating];
}
