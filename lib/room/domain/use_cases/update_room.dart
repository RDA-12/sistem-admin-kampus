import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/room/domain/entities.dart';
import 'package:sistem_admin/room/domain/repository.dart';

/// Params for updating a [Room]
final class UpdateRoomParams extends Equatable {
  /// Creates new [UpdateRoomParams]
  const new(
    this.room, {
    this.name,
    this.facultyId,
  });

  /// Room that will be updated
  final Room room;

  /// Updated name
  final String? name;

  /// Updated faculty ID
  final String? facultyId;

  @override
  List<Object?> get props => [room, name, facultyId];
}

/// Use case for updating a [Room]
@LazySingleton(env: [Environment.prod])
class UpdateRoomUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<UpdateRoomParams, Room> {
  /// Creates new [UpdateRoomUseCase]
  new({required this._roomRepository});

  final IRoomRepository _roomRepository;

  @override
  Future<AppResult<Room>> call(UpdateRoomParams params) async {
    logDebug(
      'start updating room',
      extra: {
        'id': params.room.id,
        'name': params.name,
        'facultyId': params.facultyId,
      },
    );
    final result = await _roomRepository.update(
      params.room.id,
      args: params,
    );
    switch (result) {
      case AppSuccess(:final data):
        logDebug('room updated');
        return AppResult.success(data);
      case AppFailure<Room>(:final exception):
        logDebug('room update failed');
        return AppResult.failure(exception);
    }
  }
}
