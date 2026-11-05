import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/domain/domain.dart';
import 'package:sistem_admin/program/program.dart';
import 'package:sistem_admin/room/room.dart';

part 'faculty_detail_event.dart';
part 'faculty_detail_state.dart';

/// Bloc for streaming a [Faculty] data changes
@Injectable(env: [Environment.prod])
class FacultyDetailBloc extends Bloc<FacultyDetailEvent, FacultyDetailState>
    with AppLoggerMixin {
  /// Creates new [FacultyDetailBloc]
  new({
    required this._watchSingleFaculty,
    required this._watchPrograms,
    required this._watchRooms,
  }) : super(const FacultyDetailInitial()) {
    on<FacultyDetailSubscriptionRequested>(
      _onFacultyDetailSubscriptionRequested,
      transformer: restartable(),
    );
  }

  final WatchSingleFacultyUseCase _watchSingleFaculty;
  final WatchProgramsUseCase _watchPrograms;
  final WatchRoomsUseCase _watchRooms;

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

      final stream = CombineLatestStream.combine3(
        _watchSingleFaculty(event.id),
        _watchPrograms(ProgramFilter(facultyId: event.id)),
        _watchRooms(RoomFilter(facultyId: event.id)),
        (facultyResult, programsResult, roomsResult) {
          late final Faculty faculty;
          switch (facultyResult) {
            case AppFailure<Faculty>(:final exception):
              return AppResult<FacultyDetailLoaded>.failure(exception);
            case AppSuccess<Faculty>(:final data):
              faculty = data;
          }
          late final List<Program> programs;
          switch (programsResult) {
            case AppFailure<List<Program>>(:final exception):
              return AppResult<FacultyDetailLoaded>.failure(exception);
            case AppSuccess<List<Program>>(:final data):
              programs = data;
          }
          switch (roomsResult) {
            case AppFailure<List<Room>>(:final exception):
              return AppResult<FacultyDetailLoaded>.failure(exception);
            case AppSuccess<List<Room>>(:final data):
              return AppResult.success(
                FacultyDetailLoaded(
                  faculty: faculty,
                  programs: programs,
                  rooms: data,
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
