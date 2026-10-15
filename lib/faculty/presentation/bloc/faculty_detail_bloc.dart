import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/domain/domain.dart';
import 'package:sistem_admin/program/program.dart';

part 'faculty_detail_event.dart';
part 'faculty_detail_state.dart';

/// Bloc for streaming a [Faculty] data changes
@Injectable(env: [Environment.prod])
class FacultyDetailBloc extends Bloc<FacultyDetailEvent, FacultyDetailState>
    with AppLoggerMixin {
  /// Creates new [FacultyDetailBloc]
  new({
    required this._watchSingleFaculty,
    required this._watchProgramsByFaculty,
  }) : super(const FacultyDetailInitial()) {
    on<FacultyDetailSubscriptionRequested>(
      _onFacultyDetailSubscriptionRequested,
      transformer: restartable(),
    );
  }

  final WatchSingleFacultyUseCase _watchSingleFaculty;
  final WatchProgramsByFacultyUseCase _watchProgramsByFaculty;

  Future<void> _onFacultyDetailSubscriptionRequested(
    FacultyDetailSubscriptionRequested event,
    Emitter<FacultyDetailState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'starts subscribe to faculty detail changes. emits loading',
        extra: {'id': event.id},
      );
      emit(const LoadingFacultyDetail());

      final stream = CombineLatestStream.combine2(
        _watchSingleFaculty(event.id),
        _watchProgramsByFaculty(event.id),
        (facultyResult, programsResult) {
          late final Faculty faculty;
          switch (facultyResult) {
            case AppFailure<Faculty>(:final exception):
              return AppResult<FacultyDetailLoaded>.failure(exception);
            case AppSuccess<Faculty>(:final data):
              faculty = data;
          }
          switch (programsResult) {
            case AppFailure<List<Program>>(:final exception):
              return AppResult<FacultyDetailLoaded>.failure(exception);
            case AppSuccess<List<Program>>(:final data):
              return AppResult.success(
                FacultyDetailLoaded(
                  faculty: faculty,
                  programs: data,
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
              logDebug('new faculty detail received. emit loaded');
              return data;
            case AppFailure(:final exception):
              logDebug('failure result received. emit failure');
              return FacultyDetailLoadFailed(exception: exception);
          }
        },
      );
    });
  }
}
