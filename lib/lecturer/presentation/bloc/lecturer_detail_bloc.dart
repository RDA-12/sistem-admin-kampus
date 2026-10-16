import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/lecturer/domain/domain.dart';
import 'package:sistem_admin/lecturer/presentation/models.dart';
import 'package:sistem_admin/program/program.dart';

part 'lecturer_detail_event.dart';
part 'lecturer_detail_state.dart';

/// Bloc for streaming a [Lecturer] data changes
@Injectable(env: [Environment.prod])
class LecturerDetailBloc extends Bloc<LecturerDetailEvent, LecturerDetailState>
    with AppLoggerMixin {
  /// Creates new [LecturerDetailBloc]
  new({
    required this._watchSingleLecturer,
    required this._watchPrograms,
  }) : super(const LecturerDetailInitial()) {
    on<LecturerDetailSubscriptionRequested>(
      _onLecturerDetailSubscriptionRequested,
      transformer: restartable(),
    );
  }

  final WatchSingleLecturerUseCase _watchSingleLecturer;
  final WatchProgramsUseCase _watchPrograms;

  Future<void> _onLecturerDetailSubscriptionRequested(
    LecturerDetailSubscriptionRequested event,
    Emitter<LecturerDetailState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'starts subscribe to lecturer detail changes. emits loading',
        extra: {'id': event.id},
      );
      emit(const LoadingLecturerDetail());

      final stream = CombineLatestStream.combine2(
        _watchPrograms(null),
        _watchSingleLecturer(event.id),
        (programsResult, lecturerResult) {
          late final List<Program> programs;
          switch (programsResult) {
            case AppFailure<List<Program>>(:final exception):
              return AppResult<LecturerUI>.failure(exception);
            case AppSuccess<List<Program>>(:final data):
              programs = data;
          }
          switch (lecturerResult) {
            case AppFailure<Lecturer>(:final exception):
              return AppResult<LecturerUI>.failure(exception);
            case AppSuccess<Lecturer>(:final data):
              final program = programs.firstWhereOrNull(
                (it) => it.id == data.programId,
              );
              if (program == null) {
                return AppResult<LecturerUI>.failure(
                  const AppException(
                    'program not found',
                    code: .lecturerNotFound,
                  ),
                );
              }
              return AppResult.success(
                LecturerUI(
                  id: data.id,
                  programId: data.programId,
                  name: data.name,
                  pangkatGolongan: data.pangkatGolongan,
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
              logDebug('new lecturer detail received. emit loaded');
              return LecturerDetailLoaded(lecturer: data);
            case AppFailure(:final exception):
              logDebug('failure result received. emit failure');
              return LecturerDetailLoadFailed(exception: exception);
          }
        },
      );
    });
  }
}
