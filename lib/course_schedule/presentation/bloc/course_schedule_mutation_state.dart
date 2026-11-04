part of 'course_schedule_mutation_bloc.dart';

/// Possible types of course schedule mutation
enum CourseScheduleMutationType {
  /// Create type
  create,

  /// Update type
  update,

  /// Delete type
  delete,
}

/// Notice data for [CourseScheduleMutationState]
sealed class CourseScheduleMutationNotice extends Equatable {
  const new();
}

/// Notice when a [CourseSchedule] has been updated from [before] to
/// [after]
final class CourseScheduleUpdatedNotice extends CourseScheduleMutationNotice {
  /// Creates new [CourseScheduleUpdatedNotice]
  const new({required this.before, required this.after});

  /// [CourseSchedule] data before update
  final CourseSchedule before;

  /// [CourseSchedule] data after update
  final CourseSchedule after;

  @override
  List<Object?> get props => [before, after];
}

/// Notice when a [CourseSchedule] has been deleted
final class CourseScheduleDeletedNotice extends CourseScheduleMutationNotice {
  /// Creates new [CourseScheduleDeletedNotice] for [deleted]
  const new(this.deleted);

  /// Deleted [CourseSchedule]
  final CourseSchedule deleted;

  @override
  List<Object?> get props => [deleted];
}

/// Notice when a [CourseSchedule] has been created
final class CourseScheduleCreatedNotice extends CourseScheduleMutationNotice {
  /// Creates new [CourseScheduleCreatedNotice] for [created]
  const new(this.created);

  /// Created [CourseSchedule]
  final CourseSchedule created;

  @override
  List<Object?> get props => [created];
}

/// Notice when course schedule mutation process failed
final class CourseScheduleMutationFailedNotice
    extends CourseScheduleMutationNotice {
  /// Creates new [CourseScheduleMutationFailedNotice]
  const new({
    required this.exception,
    required this.type,
    required this.courseSchedule,
  });

  /// Type of failed mutation
  final CourseScheduleMutationType type;

  /// Course schedule that was included
  ///
  /// It will be null when [type] is [CourseScheduleMutationType.create]
  final CourseSchedule? courseSchedule;

  /// Exception thrown by failed mutation
  final AppException exception;

  @override
  List<Object?> get props => [type, courseSchedule, exception];
}

/// State for [CourseScheduleMutationBloc]
class CourseScheduleMutationState extends Equatable {
  /// Creates new [CourseScheduleMutationState]
  const new({
    this.isCreating = false,
    this.notice,
    this.deletingIds = const {},
    this.updatingIds = const {},
  });

  /// Notice for newly completed mutation process
  final CourseScheduleMutationNotice? notice;

  /// List of [CourseSchedule] ID for delete
  final Set<String> deletingIds;

  /// List of [CourseSchedule] ID for update
  final Set<String> updatingIds;

  /// Whether creating new [CourseSchedule] or not
  final bool isCreating;

  /// Returns new copy based on provided data
  CourseScheduleMutationState copyWith({
    CourseScheduleMutationNotice? notice,
    Set<String>? deletingIds,
    Set<String>? updatingIds,
    bool? isCreating,
  }) {
    return CourseScheduleMutationState(
      notice: notice ?? this.notice,
      deletingIds: deletingIds ?? this.deletingIds,
      updatingIds: updatingIds ?? this.updatingIds,
      isCreating: isCreating ?? this.isCreating,
    );
  }

  @override
  List<Object?> get props => [notice, deletingIds, updatingIds, isCreating];
}
