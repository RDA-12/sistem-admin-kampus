import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/domain/domain.dart';

part 'course_mutation_event.dart';
part 'course_mutation_state.dart';

/// Bloc for mutating [Course] data
@injectable
class CourseMutationBloc extends Bloc<CourseMutationEvent, CourseMutationState>
    with AppLoggerMixin {
  /// Creates new [CourseMutationBloc]
  new({
    required this._createCourse,
    required this._updateCourse,
    required this._deleteCourse,
  }) : super(const CourseMutationState()) {
    on<CourseMutationCreateRequested>(
      _onCourseMutationCreateRequested,
      transformer: sequential(),
    );
    on<CourseMutationUpdateRequested>(
      _onCourseMutationUpdateRequested,
    );
    on<CourseMutationDeleteRequested>(
      _onCourseMutationDeleteRequested,
    );
  }

  final CreateCourseUseCase _createCourse;
  final UpdateCourseUseCase _updateCourse;
  final DeleteCourseUseCase _deleteCourse;

  Future<void> _onCourseMutationCreateRequested(
    CourseMutationCreateRequested event,
    Emitter<CourseMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start creating course. emit isCreating true',
        extra: {
          'programId': event.programId,
          'code': event.code,
          'name': event.name,
          'semester': event.semester,
          'credit': event.credit,
        },
      );
      emit(state.copyWith(isCreating: true));

      final result = await _createCourse(
        CreateCourseParams(
          programId: event.programId,
          code: event.code,
          name: event.name,
          semester: event.semester,
          credit: event.credit,
        ),
      );

      final notice = switch (result) {
        AppSuccess(:final data) => () {
          logDebug('course created. emit created notice');
          return CourseCreatedNotice(data);
        }(),
        AppFailure(:final exception) => () {
          logDebug('create course failed. emit failure notice');
          return CourseMutationFailedNotice(
            type: CourseMutationType.create,
            exception: exception,
            course: null,
          );
        }(),
      };
      emit(state.copyWith(isCreating: false, notice: notice));
    });
  }

  Future<void> _onCourseMutationUpdateRequested(
    CourseMutationUpdateRequested event,
    Emitter<CourseMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start updating course. emit updatingIds',
        extra: {
          'id': event.course.id,
          'code': event.code,
          'name': event.name,
          'semester': event.semester,
          'credit': event.credit,
          'programId': event.programId,
        },
      );
      emit(
        state.copyWith(
          updatingIds: {...state.updatingIds, event.course.id},
        ),
      );

      final result = await _updateCourse(
        UpdateCourseParams(
          event.course,
          code: event.code,
          name: event.name,
          semester: event.semester,
          credit: event.credit,
          programId: event.programId,
        ),
      );

      final notice = switch (result) {
        AppSuccess(:final data) => () {
          logDebug('course updated. emit updated notice');
          return CourseUpdatedNotice(
            before: event.course,
            after: data,
          );
        }(),
        AppFailure(:final exception) => () {
          logDebug('update course failed. emit failure notice');
          return CourseMutationFailedNotice(
            type: CourseMutationType.update,
            exception: exception,
            course: event.course,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          updatingIds: {...state.updatingIds}..remove(event.course.id),
        ),
      );
    });
  }

  Future<void> _onCourseMutationDeleteRequested(
    CourseMutationDeleteRequested event,
    Emitter<CourseMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start deleting course. emit deletingIds',
        extra: {'id': event.course.id},
      );
      emit(
        state.copyWith(
          deletingIds: {...state.deletingIds, event.course.id},
        ),
      );

      final result = await _deleteCourse(event.course);

      final notice = switch (result) {
        AppSuccess() => () {
          logDebug('course deleted. emit deleted notice');
          return CourseDeletedNotice(event.course);
        }(),
        AppFailure(:final exception) => () {
          logDebug('delete course failed. emit failure notice');
          return CourseMutationFailedNotice(
            type: CourseMutationType.delete,
            exception: exception,
            course: event.course,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          deletingIds: {...state.deletingIds}..remove(event.course.id),
        ),
      );
    });
  }
}
