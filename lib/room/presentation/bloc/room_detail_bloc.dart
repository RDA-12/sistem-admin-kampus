import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/room/domain/domain.dart';
import 'package:sistem_admin/room/presentation/models.dart';

part 'room_detail_event.dart';
part 'room_detail_state.dart';

/// Bloc for streaming a [Room] data changes
@Injectable(env: [Environment.prod])
class RoomDetailBloc extends Bloc<RoomDetailEvent, RoomDetailState>
    with AppLoggerMixin {
  /// Creates new [RoomDetailBloc]
  new({
    required this._watchSingleRoom,
    required this._watchFaculties,
  }) : super(const RoomDetailInitial()) {
    on<RoomDetailSubscriptionRequested>(
      _onRoomDetailSubscriptionRequested,
      transformer: restartable(),
    );
  }

  final WatchSingleRoomUseCase _watchSingleRoom;
  final WatchFacultiesUseCase _watchFaculties;

  Future<void> _onRoomDetailSubscriptionRequested(
    RoomDetailSubscriptionRequested event,
    Emitter<RoomDetailState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'starts subscribe to room detail changes. emits loading',
        extra: {'id': event.id},
      );
      emit(const LoadingRoomDetail());

      final stream = CombineLatestStream.combine2(
        _watchFaculties(null),
        _watchSingleRoom(event.id),
        (facultiesResult, roomResult) {
          late final List<Faculty> faculties;
          switch (facultiesResult) {
            case AppFailure<List<Faculty>>(:final exception):
              return AppResult<RoomUI>.failure(exception);
            case AppSuccess<List<Faculty>>(:final data):
              faculties = data;
          }
          switch (roomResult) {
            case AppFailure<Room>(:final exception):
              return AppResult<RoomUI>.failure(exception);
            case AppSuccess<Room>(:final data):
              final faculty = faculties.firstWhereOrNull(
                (it) => it.id == data.facultyId,
              );
              if (faculty == null) {
                return AppResult<RoomUI>.failure(
                  const AppException(
                    'faculty not found',
                    code: .roomNotFound,
                  ),
                );
              }
              return AppResult.success(
                RoomUI(
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
              logDebug('new room detail received. emit loaded');
              return RoomDetailLoaded(room: data);
            case AppFailure(:final exception):
              logDebug('failure result received. emit failure');
              return RoomDetailLoadFailed(exception: exception);
          }
        },
      );
    });
  }
}
