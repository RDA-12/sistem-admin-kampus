part of 'course_schedule_event_mutation_bloc.dart';

/// Possible types of course schedule event mutation
enum CourseScheduleEventMutationType {
  /// Create type
  create,

  /// Update type
  update,

  /// Delete type
  delete,
}

/// Notice data for [CourseScheduleEventMutationState]
sealed class CourseScheduleEventMutationNotice extends Equatable {
  const new();
}

/// Notice when a [CourseScheduleEvent] has been updated from [before] to
/// [after]
final class CourseScheduleEventUpdatedNotice
    extends CourseScheduleEventMutationNotice {
  /// Creates new [CourseScheduleEventUpdatedNotice]
  const new({required this.before, required this.after});

  /// [CourseScheduleEvent] data before update
  final CourseScheduleEvent before;

  /// [CourseScheduleEvent] data after update
  final CourseScheduleEvent after;

  @override
  List<Object?> get props => [before, after];
}

/// Notice when a [CourseScheduleEvent] has been deleted
final class CourseScheduleEventDeletedNotice
    extends CourseScheduleEventMutationNotice {
  /// Creates new [CourseScheduleEventDeletedNotice] for [deleted]
  const new(this.deleted);

  /// Deleted [CourseScheduleEvent]
  final CourseScheduleEvent deleted;

  @override
  List<Object?> get props => [deleted];
}

/// Notice when a [CourseScheduleEvent] has been created
final class CourseScheduleEventCreatedNotice
    extends CourseScheduleEventMutationNotice {
  /// Creates new [CourseScheduleEventCreatedNotice] for [created]
  const new(this.created);

  /// Created [CourseScheduleEvent]
  final CourseScheduleEvent created;

  @override
  List<Object?> get props => [created];
}

/// Notice when course schedule event mutation process failed
final class CourseScheduleEventMutationFailedNotice
    extends CourseScheduleEventMutationNotice {
  /// Creates new [CourseScheduleEventMutationFailedNotice]
  const new({
    required this.exception,
    required this.type,
    required this.event,
  });

  /// Type of failed mutation
  final CourseScheduleEventMutationType type;

  /// Event that was included
  ///
  /// It will be null when [type] is [CourseScheduleEventMutationType.create]
  final CourseScheduleEvent? event;

  /// Exception thrown by failed mutation
  final AppException exception;

  @override
  List<Object?> get props => [type, event, exception];
}

/// State for [CourseScheduleEventMutationBloc]
class CourseScheduleEventMutationState extends Equatable {
  /// Creates new [CourseScheduleEventMutationState]
  const new({
    this.isCreating = false,
    this.notice,
    this.deletingIds = const {},
    this.updatingIds = const {},
  });

  /// Notice for newly completed mutation process
  final CourseScheduleEventMutationNotice? notice;

  /// List of [CourseScheduleEvent] ID for delete
  final Set<String> deletingIds;

  /// List of [CourseScheduleEvent] ID for update
  final Set<String> updatingIds;

  /// Whether creating new [CourseScheduleEvent] or not
  final bool isCreating;

  /// Returns new copy based on provided data
  CourseScheduleEventMutationState copyWith({
    CourseScheduleEventMutationNotice? notice,
    Set<String>? deletingIds,
    Set<String>? updatingIds,
    bool? isCreating,
  }) {
    return CourseScheduleEventMutationState(
      notice: notice ?? this.notice,
      deletingIds: deletingIds ?? this.deletingIds,
      updatingIds: updatingIds ?? this.updatingIds,
      isCreating: isCreating ?? this.isCreating,
    );
  }

  @override
  List<Object?> get props => [notice, deletingIds, updatingIds, isCreating];
}
