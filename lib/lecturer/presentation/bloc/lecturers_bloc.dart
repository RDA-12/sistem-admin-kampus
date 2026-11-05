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

part 'lecturers_event.dart';
part 'lecturers_state.dart';

/// Bloc for watching [Lecturer] data changes
@injectable
class LecturersBloc extends Bloc<LecturersEvent, LecturersState>
    with AppLoggerMixin {
  /// Creates new [LecturersBloc]
  new({
    required this._watchLecturers,
    required this._watchPrograms,
  }) : super(const LecturersInitial()) {
    on<LecturersSubscriptionRequested>(
      _onLecturersSubscriptionRequested,
      transformer: droppable(),
    );
  }

  final WatchLecturersUseCase _watchLecturers;
  final WatchProgramsUseCase _watchPrograms;

  Future<void> _onLecturersSubscriptionRequested(
    LecturersSubscriptionRequested event,
    Emitter<LecturersState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug('starts subscribe to lecturers changes. emits loading');
      emit(const LoadingLecturers());
      final stream = CombineLatestStream.combine2(
        _watchPrograms(),
        _watchLecturers(),
        (programsResult, lecturersResult) {
          late final List<Program> programs;
          switch (programsResult) {
            case AppFailure<List<Program>>(:final exception):
              return AppResult<List<LecturerUI>>.failure(exception);
            case AppSuccess<List<Program>>(:final data):
              programs = data;
          }
          switch (lecturersResult) {
            case AppFailure<List<Lecturer>>(:final exception):
              return AppResult<List<LecturerUI>>.failure(exception);
            case AppSuccess<List<Lecturer>>(:final data):
              final result = <LecturerUI>[];
              for (final it in data) {
                final program = programs.firstWhereOrNull(
                  (v) => v.id == it.programId,
                );
                if (program == null) continue;
                result.add(
                  LecturerUI(
                    id: it.id,
                    programId: it.programId,
                    name: it.name,
                    pangkatGolongan: it.pangkatGolongan,
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
              logDebug('new lecturers received. emit loaded');
              return LecturersLoaded(data);
            case AppFailure(:final exception):
              logDebug('failure result received. emit failure');
              return LecturersFailure(exception);
          }
        },
      );
    });
  }
}
