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

part 'courses_event.dart';
part 'courses_state.dart';

/// Bloc for watching [Course] data changes
@injectable
class CoursesBloc extends Bloc<CoursesEvent, CoursesState> with AppLoggerMixin {
  /// Creates new [CoursesBloc]
  new({
    required this._watchCourses,
    required this._watchPrograms,
  }) : super(const CoursesInitial()) {
    on<CoursesSubscriptionRequested>(
      _onCoursesSubscriptionRequested,
      transformer: droppable(),
    );
  }

  final WatchCoursesUseCase _watchCourses;
  final WatchProgramsUseCase _watchPrograms;

  Future<void> _onCoursesSubscriptionRequested(
    CoursesSubscriptionRequested event,
    Emitter<CoursesState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug('starts subscribe to courses changes. emits loading');
      emit(const LoadingCourses());
      final stream = CombineLatestStream.combine2(
        _watchPrograms(),
        _watchCourses(),
        (programsResult, coursesResult) {
          late final List<Program> programs;
          switch (programsResult) {
            case AppFailure<List<Program>>(:final exception):
              return AppResult<List<CourseUI>>.failure(exception);
            case AppSuccess<List<Program>>(:final data):
              programs = data;
          }
          switch (coursesResult) {
            case AppFailure<List<Course>>(:final exception):
              return AppResult<List<CourseUI>>.failure(exception);
            case AppSuccess<List<Course>>(:final data):
              final result = <CourseUI>[];
              for (final it in data) {
                final program = programs.firstWhereOrNull(
                  (v) => v.id == it.programId,
                );
                if (program == null) continue;
                result.add(
                  CourseUI(
                    id: it.id,
                    programId: it.programId,
                    code: it.code,
                    name: it.name,
                    semester: it.semester,
                    credit: it.credit,
                    program: program,
                  ),
                );
              }
              return AppResult.success(result);
          }
        },
      );

      await emit.forEach(
        stream,
        onData: (result) {
          switch (result) {
            case AppSuccess(:final data):
              logDebug('new courses received. emit loaded');
              return CoursesLoaded(data);
            case AppFailure(:final exception):
              logDebug('failure result received. emit failure');
              return CoursesFailure(exception);
          }
        },
      );
    });
  }
}
