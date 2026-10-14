import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/program/domain/domain.dart';
import 'package:sistem_admin/program/presentation/models.dart';

part 'programs_event.dart';
part 'programs_state.dart';

/// Bloc for watching [Program] data changes
@injectable
class ProgramsBloc extends Bloc<ProgramsEvent, ProgramsState>
    with AppLoggerMixin {
  /// Creates new [ProgramsBloc]
  new({
    required this._watchPrograms,
    required this._watchFaculties,
  }) : super(const ProgramsInitial()) {
    on<ProgramsSubscriptionRequested>(
      _onProgramsSubscriptionRequested,
      transformer: droppable(),
    );
  }

  final WatchProgramsUseCase _watchPrograms;
  final WatchFacultiesUseCase _watchFaculties;

  Future<void> _onProgramsSubscriptionRequested(
    ProgramsSubscriptionRequested event,
    Emitter<ProgramsState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug('starts subscribe to programs changes. emits loading');
      emit(const LoadingPrograms());
      final stream = CombineLatestStream.combine2(
        _watchFaculties(null),
        _watchPrograms(null),
        (facultiesResult, programsResult) {
          late final List<Faculty> faculties;
          switch (facultiesResult) {
            case AppFailure<List<Faculty>>(:final exception):
              return AppResult<List<ProgramUI>>.failure(exception);
            case AppSuccess<List<Faculty>>(:final data):
              faculties = data;
          }
          switch (programsResult) {
            case AppFailure<List<Program>>(:final exception):
              return AppResult<List<ProgramUI>>.failure(exception);
            case AppSuccess<List<Program>>(:final data):
              final result = <ProgramUI>[];
              for (final it in data) {
                final faculty = faculties.firstWhereOrNull(
                  (v) => v.id == it.facultyId,
                );
                if (faculty == null) continue;
                result.add(
                  ProgramUI(
                    id: it.id,
                    facultyId: it.facultyId,
                    name: it.name,
                    faculty: faculty,
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
              logDebug('new programs received. emit loaded');
              return ProgramsLoaded(data);
            case AppFailure(:final exception):
              logDebug('failure result received. emit failure');
              return ProgramsFailure(exception);
          }
        },
      );
    });
  }
}
