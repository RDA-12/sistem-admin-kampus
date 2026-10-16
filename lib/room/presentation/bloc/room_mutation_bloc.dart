import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/room/domain/domain.dart';

part 'room_mutation_event.dart';
part 'room_mutation_state.dart';

/// Bloc for mutating [Room] data
@injectable
class RoomMutationBloc extends Bloc<RoomMutationEvent, RoomMutationState>
    with AppLoggerMixin {
  /// Creates new [RoomMutationBloc]
  new({
    required this._createRoom,
    required this._updateRoom,
    required this._deleteRoom,
  }) : super(const RoomMutationState()) {
    on<RoomMutationCreateRequested>(
      _onRoomMutationCreateRequested,
      transformer: sequential(),
    );
    on<RoomMutationUpdateRequested>(
      _onRoomMutationUpdateRequested,
    );
    on<RoomMutationDeleteRequested>(
      _onRoomMutationDeleteRequested,
    );
  }

  final CreateRoomUseCase _createRoom;
  final UpdateRoomUseCase _updateRoom;
  final DeleteRoomUseCase _deleteRoom;

  Future<void> _onRoomMutationCreateRequested(
    RoomMutationCreateRequested event,
    Emitter<RoomMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start creating room. emit isCreating true',
        extra: {
          'facultyId': event.facultyId,
          'name': event.name,
        },
      );
      emit(state.copyWith(isCreating: true));

      final result = await _createRoom(
        CreateRoomParams(
          facultyId: event.facultyId,
          name: event.name,
        ),
      );

      final notice = switch (result) {
        AppSuccess(:final data) => () {
          logDebug('room created. emit created notice');
          return RoomCreatedNotice(data);
        }(),
        AppFailure(:final exception) => () {
          logDebug('create room failed. emit failure notice');
          return RoomMutationFailedNotice(
            type: RoomMutationType.create,
            exception: exception,
            room: null,
          );
        }(),
      };
      emit(state.copyWith(isCreating: false, notice: notice));
    });
  }

  Future<void> _onRoomMutationUpdateRequested(
    RoomMutationUpdateRequested event,
    Emitter<RoomMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start updating room. emit updatingIds',
        extra: {
          'id': event.room.id,
          'name': event.name,
          'facultyId': event.facultyId,
        },
      );
      emit(
        state.copyWith(
          updatingIds: {...state.updatingIds, event.room.id},
        ),
      );

      final result = await _updateRoom(
        UpdateRoomParams(
          event.room,
          name: event.name,
          facultyId: event.facultyId,
        ),
      );

      final notice = switch (result) {
        AppSuccess(:final data) => () {
          logDebug('room updated. emit updated notice');
          return RoomUpdatedNotice(
            before: event.room,
            after: data,
          );
        }(),
        AppFailure(:final exception) => () {
          logDebug('update room failed. emit failure notice');
          return RoomMutationFailedNotice(
            type: RoomMutationType.update,
            exception: exception,
            room: event.room,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          updatingIds: {...state.updatingIds}..remove(event.room.id),
        ),
      );
    });
  }

  Future<void> _onRoomMutationDeleteRequested(
    RoomMutationDeleteRequested event,
    Emitter<RoomMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start deleting room. emit deletingIds',
        extra: {'id': event.room.id},
      );
      emit(
        state.copyWith(
          deletingIds: {...state.deletingIds, event.room.id},
        ),
      );

      final result = await _deleteRoom(event.room);

      final notice = switch (result) {
        AppSuccess() => () {
          logDebug('room deleted. emit deleted notice');
          return RoomDeletedNotice(event.room);
        }(),
        AppFailure(:final exception) => () {
          logDebug('delete room failed. emit failure notice');
          return RoomMutationFailedNotice(
            type: RoomMutationType.delete,
            exception: exception,
            room: event.room,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          deletingIds: {...state.deletingIds}..remove(event.room.id),
        ),
      );
    });
  }
}
