part of 'course_mutation_bloc.dart';

/// Possible types of course mutation
enum CourseMutationType {
  /// Create type
  create,

  /// Update type
  update,

  /// Delete type
  delete,
}

/// Notice data for [CourseMutationState]
///
/// Typically used to shows dialog/toast on UI
sealed class CourseMutationNotice extends Equatable {
  const new();
}

/// Notice when a [Course] has been updated from [before] to [after]
final class CourseUpdatedNotice extends CourseMutationNotice {
  /// Creates new [CourseUpdatedNotice]
  ///
  /// A [Course] has been updated from [before] to [after]
  const new({required this.before, required this.after});

  /// [Course] data before update
  final Course before;

  /// [Course] data after update
  final Course after;

  @override
  List<Object?> get props => [before, after];
}

/// Notice when a [Course] has been deleted
final class CourseDeletedNotice extends CourseMutationNotice {
  /// Creates new [CourseDeletedNotice] for [deleted]
  const new(this.deleted);

  /// Deleted [Course]
  final Course deleted;

  @override
  List<Object?> get props => [deleted];
}

/// Notice when a [Course] has been created
final class CourseCreatedNotice extends CourseMutationNotice {
  /// Creates new [CourseCreatedNotice] for [created]
  const new(this.created);

  /// Created [Course]
  final Course created;

  @override
  List<Object?> get props => [created];
}

/// Notice when mutation process failed
final class CourseMutationFailedNotice extends CourseMutationNotice {
  /// Creates new [CourseMutationFailedNotice] for [type] and [course]
  const new({
    required this.exception,
    required this.type,
    required this.course,
  });

  /// Type of failed mutation
  final CourseMutationType type;

  /// Course that included
  ///
  /// It will be null when [type] is [CourseMutationType.create]
  final Course? course;

  /// Exception thrown by failed mutation
  final AppException exception;

  @override
  List<Object?> get props => [type, course, exception];
}

/// State for [CourseMutationBloc]
class CourseMutationState extends Equatable {
  /// Creates new [CourseMutationState]
  const new({
    this.isCreating = false,
    this.notice,
    this.deletingIds = const {},
    this.updatingIds = const {},
  });

  /// Notice for newly completed mutation process
  final CourseMutationNotice? notice;

  /// List of [Course] ID for delete
  final Set<String> deletingIds;

  /// List of [Course] ID for update
  final Set<String> updatingIds;

  /// Whether creating new [Course] or not
  final bool isCreating;

  /// Returns new copy based on provided data
  CourseMutationState copyWith({
    CourseMutationNotice? notice,
    Set<String>? deletingIds,
    Set<String>? updatingIds,
    bool? isCreating,
  }) {
    return CourseMutationState(
      notice: notice ?? this.notice,
      deletingIds: deletingIds ?? this.deletingIds,
      updatingIds: updatingIds ?? this.updatingIds,
      isCreating: isCreating ?? this.isCreating,
    );
  }

  @override
  List<Object?> get props => [notice, deletingIds, updatingIds, isCreating];
}
