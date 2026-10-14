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

part 'program_detail_event.dart';
part 'program_detail_state.dart';

/// Bloc for streaming a [Program] data changes
@Injectable(env: [Environment.prod])
class ProgramDetailBloc extends Bloc<ProgramDetailEvent, ProgramDetailState>
    with AppLoggerMixin {
  /// Creates new [ProgramDetailBloc]
  new({
    required this._watchSingleProgram,
    required this._watchFaculties,
  }) : super(const ProgramDetailInitial()) {
    on<ProgramDetailSubscriptionRequested>(
      _onProgramDetailSubscriptionRequested,
      transformer: restartable(),
    );
  }

  final WatchSingleProgramUseCase _watchSingleProgram;
  final WatchFacultiesUseCase _watchFaculties;

  Future<void> _onProgramDetailSubscriptionRequested(
    ProgramDetailSubscriptionRequested event,
    Emitter<ProgramDetailState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'starts subscribe to program detail changes. emits loading',
        extra: {'id': event.id},
      );
      emit(const LoadingProgramDetail());

      final stream = CombineLatestStream.combine2(
        _watchFaculties(null),
        _watchSingleProgram(event.id),
        (facultiesResult, programResult) {
          late final List<Faculty> faculties;
          switch (facultiesResult) {
            case AppFailure<List<Faculty>>(:final exception):
              return AppResult<ProgramUI>.failure(exception);
            case AppSuccess<List<Faculty>>(:final data):
              faculties = data;
          }
          switch (programResult) {
            case AppFailure<Program>(:final exception):
              return AppResult<ProgramUI>.failure(exception);
            case AppSuccess<Program>(:final data):
              final faculty = faculties.firstWhereOrNull(
                (it) => it.id == data.facultyId,
              );
              if (faculty == null) {
                return AppResult<ProgramUI>.failure(
                  const AppException(
                  'faculty not found',
                  code: .programNotFound,
                ),
                );
              }
              return AppResult.success(
                ProgramUI(
                  id: data.id,
                  facultyId: data.facultyId,
                  name: data.name,
                  faculty: faculty,
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
              logDebug('new program detail received. emit loaded');
              return ProgramDetailLoaded(program: data);
            case AppFailure(:final exception):
              logDebug('failure result received. emit failure');
              return ProgramDetailLoadFailed(exception: exception);
          }
        },
      );
    });
  }
}
