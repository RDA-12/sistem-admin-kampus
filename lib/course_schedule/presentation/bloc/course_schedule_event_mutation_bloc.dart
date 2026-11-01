import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/domain/domain.dart';

part 'course_schedule_event_mutation_event.dart';
part 'course_schedule_event_mutation_state.dart';

/// Bloc for mutating [CourseScheduleEvent] data
@injectable
class CourseScheduleEventMutationBloc
    extends
        Bloc<CourseScheduleEventMutationEvent, CourseScheduleEventMutationState>
    with AppLoggerMixin {
  /// Creates new [CourseScheduleEventMutationBloc]
  new({
    required this._createCourseScheduleEvent,
    required this._updateCourseScheduleEvent,
    required this._deleteCourseScheduleEvent,
  }) : super(const CourseScheduleEventMutationState()) {
    on<CourseScheduleEventMutationCreateRequested>(
      _onCourseScheduleEventMutationCreateRequested,
      transformer: sequential(),
    );
    on<CourseScheduleEventMutationUpdateRequested>(
      _onCourseScheduleEventMutationUpdateRequested,
    );
    on<CourseScheduleEventMutationDeleteRequested>(
      _onCourseScheduleEventMutationDeleteRequested,
    );
  }

  final CreateCourseScheduleEventUseCase _createCourseScheduleEvent;
  final UpdateCourseScheduleEventUseCase _updateCourseScheduleEvent;
  final DeleteCourseScheduleEventUseCase _deleteCourseScheduleEvent;

  Future<void> _onCourseScheduleEventMutationCreateRequested(
    CourseScheduleEventMutationCreateRequested event,
    Emitter<CourseScheduleEventMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start creating course schedule event. emit isCreating true',
        extra: {
          'academicYearId': event.academicYearId,
          'name': event.name,
          'start': event.start,
          'end': event.end,
          'courseDetail': event.courseDetail,
        },
      );
      emit(state.copyWith(isCreating: true));

      final result = await _createCourseScheduleEvent(
        CreateCourseScheduleEventParams(
          academicYearId: event.academicYearId,
          name: event.name,
          start: event.start,
          end: event.end,
          courseDetail: event.courseDetail,
          recurrence: event.recurrence,
        ),
      );

      final notice = switch (result) {
        AppSuccess(:final data) => () {
          logDebug('course schedule event created. emit created notice');
          return CourseScheduleEventCreatedNotice(data);
        }(),
        AppFailure(:final exception) => () {
          logDebug('create course schedule event failed. emit failed notice');
          return CourseScheduleEventMutationFailedNotice(
            type: .create,
            exception: exception,
            event: null,
          );
        }(),
      };
      emit(state.copyWith(isCreating: false, notice: notice));
    });
  }

  Future<void> _onCourseScheduleEventMutationUpdateRequested(
    CourseScheduleEventMutationUpdateRequested event,
    Emitter<CourseScheduleEventMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start updating course schedule event. emit updatingIds',
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

      final result = await _updateCourseScheduleEvent(
        UpdateCourseScheduleEventParams(
          event.event,
          academicYearId: event.academicYearId,
          name: event.name,
          start: event.start,
          end: event.end,
          courseDetail: event.courseDetail,
          cohortId: event.cohortId,
          courseId: event.courseId,
          programId: event.programId,
          lecturerId: event.lecturerId,
          roomId: event.roomId,
          recurrence: event.recurrence,
        ),
      );

      final notice = switch (result) {
        AppSuccess(:final data) => () {
          logDebug('course schedule event updated. emit updated notice');
          return CourseScheduleEventUpdatedNotice(
            before: event.event,
            after: data,
          );
        }(),
        AppFailure(:final exception) => () {
          logDebug('update course schedule event failed. emit failed notice');
          return CourseScheduleEventMutationFailedNotice(
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

  Future<void> _onCourseScheduleEventMutationDeleteRequested(
    CourseScheduleEventMutationDeleteRequested event,
    Emitter<CourseScheduleEventMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start deleting course schedule event. emit deletingIds',
        extra: {'id': event.event.id},
      );
      emit(
        state.copyWith(
          deletingIds: {...state.deletingIds, event.event.id},
        ),
      );

      final result = await _deleteCourseScheduleEvent(event.event);

      final notice = switch (result) {
        AppSuccess() => () {
          logDebug('course schedule event deleted. emit deleted notice');
          return CourseScheduleEventDeletedNotice(event.event);
        }(),
        AppFailure(:final exception) => () {
          logDebug('delete course schedule event failed. emit failed notice');
          return CourseScheduleEventMutationFailedNotice(
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
