part of 'academic_calendar_mutation_bloc.dart';

/// Possible types of academic calendar mutation
enum AcademicCalendarMutationType {
  /// Create type
  create,

  /// Update type
  update,

  /// Delete type
  delete,
}

/// Possible target entities of academic calendar mutation
enum AcademicCalendarTargetType {
  /// Academic Year target
  year,

  /// Academic Term target
  term,
}

/// Notice data for [AcademicCalendarMutationState]
///
/// Typically used to shows dialog/toast on UI
sealed class AcademicCalendarMutationNotice extends Equatable {
  const new();
}

/// Notice when an [AcademicYear] has been updated from [before] to [after]
final class AcademicYearUpdatedNotice extends AcademicCalendarMutationNotice {
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
final class AcademicYearDeletedNotice extends AcademicCalendarMutationNotice {
  /// Creates new [AcademicYearDeletedNotice] for [deleted]
  const new(this.deleted);

  /// Deleted [AcademicYear]
  final AcademicYear deleted;

  @override
  List<Object?> get props => [deleted];
}

/// Notice when an [AcademicYear] has been created
final class AcademicYearCreatedNotice extends AcademicCalendarMutationNotice {
  /// Creates new [AcademicYearCreatedNotice] for [created]
  const new(this.created);

  /// Created [AcademicYear]
  final AcademicYear created;

  @override
  List<Object?> get props => [created];
}

/// Notice when an [AcademicTerm] has been updated from [before] to [after]
final class AcademicTermUpdatedNotice extends AcademicCalendarMutationNotice {
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
final class AcademicTermDeletedNotice extends AcademicCalendarMutationNotice {
  /// Creates new [AcademicTermDeletedNotice] for [deleted]
  const new(this.deleted);

  /// Deleted [AcademicTerm]
  final AcademicTerm deleted;

  @override
  List<Object?> get props => [deleted];
}

/// Notice when an [AcademicTerm] has been created
final class AcademicTermCreatedNotice extends AcademicCalendarMutationNotice {
  /// Creates new [AcademicTermCreatedNotice] for [created]
  const new(this.created);

  /// Created [AcademicTerm]
  final AcademicTerm created;

  @override
  List<Object?> get props => [created];
}

/// Notice when academic calendar mutation process failed
final class AcademicCalendarMutationFailedNotice
    extends AcademicCalendarMutationNotice {
  /// Creates new [AcademicCalendarMutationFailedNotice]
  const new({
    required this.exception,
    required this.type,
    required this.target,
    this.academicYear,
    this.academicTerm,
  });

  /// Type of failed mutation
  final AcademicCalendarMutationType type;

  /// Target entity type of failed mutation
  final AcademicCalendarTargetType target;

  /// Academic year that was included, if target is year
  final AcademicYear? academicYear;

  /// Academic term that was included, if target is term
  final AcademicTerm? academicTerm;

  /// Exception thrown by failed mutation
  final AppException exception;

  @override
  List<Object?> get props => [
    type,
    target,
    academicYear,
    academicTerm,
    exception,
  ];
}

/// State for [AcademicCalendarMutationBloc]
class AcademicCalendarMutationState extends Equatable {
  /// Creates new [AcademicCalendarMutationState]
  const new({
    this.isCreatingYear = false,
    this.isCreatingTerm = false,
    this.notice,
    this.deletingYearIds = const {},
    this.updatingYearIds = const {},
    this.deletingTermIds = const {},
    this.updatingTermIds = const {},
  });

  /// Notice for newly completed mutation process
  final AcademicCalendarMutationNotice? notice;

  /// List of [AcademicYear] ID for delete
  final Set<String> deletingYearIds;

  /// List of [AcademicYear] ID for update
  final Set<String> updatingYearIds;

  /// List of [AcademicTerm] ID for delete
  final Set<String> deletingTermIds;

  /// List of [AcademicTerm] ID for update
  final Set<String> updatingTermIds;

  /// Whether creating new [AcademicYear] or not
  final bool isCreatingYear;

  /// Whether creating new [AcademicTerm] or not
  final bool isCreatingTerm;

  /// Returns new copy based on provided data
  AcademicCalendarMutationState copyWith({
    AcademicCalendarMutationNotice? notice,
    Set<String>? deletingYearIds,
    Set<String>? updatingYearIds,
    Set<String>? deletingTermIds,
    Set<String>? updatingTermIds,
    bool? isCreatingYear,
    bool? isCreatingTerm,
  }) {
    return AcademicCalendarMutationState(
      notice: notice ?? this.notice,
      deletingYearIds: deletingYearIds ?? this.deletingYearIds,
      updatingYearIds: updatingYearIds ?? this.updatingYearIds,
      deletingTermIds: deletingTermIds ?? this.deletingTermIds,
      updatingTermIds: updatingTermIds ?? this.updatingTermIds,
      isCreatingYear: isCreatingYear ?? this.isCreatingYear,
      isCreatingTerm: isCreatingTerm ?? this.isCreatingTerm,
    );
  }

  @override
  List<Object?> get props => [
    notice,
    deletingYearIds,
    updatingYearIds,
    deletingTermIds,
    updatingTermIds,
    isCreatingYear,
    isCreatingTerm,
  ];
}
