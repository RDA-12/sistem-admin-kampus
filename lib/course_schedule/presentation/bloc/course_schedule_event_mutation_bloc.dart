import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/domain/domain.dart';

part 'course_schedule_event_mutation_event.dart';
part 'course_schedule_event_mutation_state.dart';

/// Bloc for mutating [CourseSchedule] data
@injectable
class CourseScheduleMutationBloc
    extends Bloc<CourseScheduleMutationEvent, CourseScheduleMutationState>
    with AppLoggerMixin {
  /// Creates new [CourseScheduleMutationBloc]
  new({
    required this._createCourseSchedule,
    required this._updateCourseSchedule,
    required this._deleteCourseSchedule,
  }) : super(const CourseScheduleMutationState()) {
    on<CourseScheduleMutationCreateRequested>(
      _onCourseScheduleMutationCreateRequested,
      transformer: sequential(),
    );
    on<CourseScheduleMutationUpdateRequested>(
      _onCourseScheduleMutationUpdateRequested,
    );
    on<CourseScheduleMutationDeleteRequested>(
      _onCourseScheduleMutationDeleteRequested,
    );
  }

  final CreateCourseScheduleUseCase _createCourseSchedule;
  final UpdateCourseScheduleUseCase _updateCourseSchedule;
  final DeleteCourseScheduleUseCase _deleteCourseSchedule;

  Future<void> _onCourseScheduleMutationCreateRequested(
    CourseScheduleMutationCreateRequested event,
    Emitter<CourseScheduleMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start creating course schedule. emit isCreating true',
        extra: {
          'academicYearId': event.academicYearId,
          'termId': event.termId,
          'name': event.name,
        },
      );
      emit(state.copyWith(isCreating: true));

      final result = await _createCourseSchedule(
        CreateCourseScheduleParams(
          academicYearId: event.academicYearId,
          termId: event.termId,
          programId: event.programId,
          name: event.name,
          start: event.start,
          duration: event.duration,
          cohortId: event.cohortId,
          courseId: event.courseId,
          lecturerId: event.lecturerId,
          roomId: event.roomId,
        ),
      );

      final notice = switch (result) {
        AppSuccess(:final data) => () {
          logDebug('course schedule created. emit created notice');
          return CourseScheduleCreatedNotice(data);
        }(),
        AppFailure(:final exception) => () {
          logDebug('create course schedule failed. emit failed notice');
          return CourseScheduleMutationFailedNotice(
            type: .create,
            exception: exception,
            event: null,
          );
        }(),
      };
      emit(state.copyWith(isCreating: false, notice: notice));
    });
  }

  Future<void> _onCourseScheduleMutationUpdateRequested(
    CourseScheduleMutationUpdateRequested event,
    Emitter<CourseScheduleMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start updating course schedule. emit updatingIds',
        extra: {
          'id': event.event.id,
          'name': event.name,
        },
      );
      emit(
        state.copyWith(
          updatingIds: {...state.updatingIds, event.event.id},
        ),
      );

      final result = await _updateCourseSchedule(
        UpdateCourseScheduleParams(
          event.event,
          academicYearId: event.academicYearId,
          termId: event.termId,
          programId: event.programId,
          name: event.name,
          start: event.start,
          duration: event.duration,
          cohortId: event.cohortId,
          courseId: event.courseId,
          lecturerId: event.lecturerId,
          roomId: event.roomId,
        ),
      );

      final notice = switch (result) {
        AppSuccess(:final data) => () {
          logDebug('course schedule updated. emit updated notice');
          return CourseScheduleUpdatedNotice(
            before: event.event,
            after: data,
          );
        }(),
        AppFailure(:final exception) => () {
          logDebug('update course schedule failed. emit failed notice');
          return CourseScheduleMutationFailedNotice(
            type: .update,
            exception: exception,
            event: event.event,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          updatingIds: {...state.updatingIds}..remove(event.event.id),
        ),
      );
    });
  }

  Future<void> _onCourseScheduleMutationDeleteRequested(
    CourseScheduleMutationDeleteRequested event,
    Emitter<CourseScheduleMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start deleting course schedule. emit deletingIds',
        extra: {'id': event.event.id},
      );
      emit(
        state.copyWith(
          deletingIds: {...state.deletingIds, event.event.id},
        ),
      );

      final result = await _deleteCourseSchedule(event.event);

      final notice = switch (result) {
        AppSuccess() => () {
          logDebug('course schedule deleted. emit deleted notice');
          return CourseScheduleDeletedNotice(event.event);
        }(),
        AppFailure(:final exception) => () {
          logDebug('delete course schedule failed. emit failed notice');
          return CourseScheduleMutationFailedNotice(
            type: .delete,
            exception: exception,
            event: event.event,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          deletingIds: {...state.deletingIds}..remove(event.event.id),
        ),
      );
    });
  }
}
