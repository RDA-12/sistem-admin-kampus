import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/domain/domain.dart';
import 'package:sistem_admin/course/presentation/models.dart';
import 'package:sistem_admin/program/program.dart';

part 'course_detail_event.dart';
part 'course_detail_state.dart';

/// Bloc for streaming a [Course] data changes
@Injectable(env: [Environment.prod])
class CourseDetailBloc extends Bloc<CourseDetailEvent, CourseDetailState>
    with AppLoggerMixin {
  /// Creates new [CourseDetailBloc]
  new({
    required this._watchSingleCourse,
    required this._watchPrograms,
  }) : super(const CourseDetailInitial()) {
    on<CourseDetailSubscriptionRequested>(
      _onCourseDetailSubscriptionRequested,
      transformer: restartable(),
    );
  }

  final WatchSingleCourseUseCase _watchSingleCourse;
  final WatchProgramsUseCase _watchPrograms;

  Future<void> _onCourseDetailSubscriptionRequested(
    CourseDetailSubscriptionRequested event,
    Emitter<CourseDetailState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'starts subscribe to course detail changes. emits loading',
        extra: {'id': event.id},
      );
      emit(const LoadingCourseDetail());

      final stream = CombineLatestStream.combine2(
        _watchPrograms(null),
        _watchSingleCourse(event.id),
        (programsResult, courseResult) {
          late final List<Program> programs;
          switch (programsResult) {
            case AppFailure<List<Program>>(:final exception):
              return AppResult<CourseUI>.failure(exception);
            case AppSuccess<List<Program>>(:final data):
              programs = data;
          }
          switch (courseResult) {
            case AppFailure<Course>(:final exception):
              return AppResult<CourseUI>.failure(exception);
            case AppSuccess<Course>(:final data):
              final program = programs.firstWhereOrNull(
                (it) => it.id == data.programId,
              );
              if (program == null) {
                return AppResult<CourseUI>.failure(
                  const AppException(
                    'program not found',
                    code: .courseNotFound,
                  ),
                );
              }
              return AppResult.success(
                CourseUI(
                  id: data.id,
                  programId: data.programId,
                  code: data.code,
                  name: data.name,
                  semester: data.semester,
                  credit: data.credit,
                  program: program,
                ),
              );
          }
        },
      );

      await emit.forEach(
        stream,
        onData: (result) {
          switch (result) {
            case AppSuccess(:final data):
              logDebug('new course detail received. emit loaded');
              return CourseDetailLoaded(course: data);
            case AppFailure(:final exception):
              logDebug('failure result received. emit failure');
              return CourseDetailLoadFailed(exception: exception);
          }
        },
      );
    });
  }
}
