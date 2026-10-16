import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/room/domain/entities.dart';
import 'package:sistem_admin/room/domain/repository.dart';

/// Use case for deleting a [Room]
@LazySingleton(env: [Environment.prod])
class DeleteRoomUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<Room, Null> {
  /// Creates new [DeleteRoomUseCase]
  new({required this._roomRepository});

  final IRoomRepository _roomRepository;

  @override
  Future<AppResult<Null>> call(Room params) async {
    logDebug('start deleting room', extra: {'id': params.id});
    final result = await _roomRepository.delete(params.id);
    switch (result) {
      case AppSuccess():
        logDebug('room deleted');
        return AppResult.success(null);
      case AppFailure<Null>(:final exception):
        logDebug('room deletion failed');
        return AppResult.failure(exception);
    }
  }
}
