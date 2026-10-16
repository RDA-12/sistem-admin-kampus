import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/room/domain/entities.dart';
import 'package:sistem_admin/room/domain/repository.dart';

/// Use case for watching single [Room] data changes
@LazySingleton(env: [Environment.prod])
class WatchSingleRoomUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<String, Room> {
  /// Creates new [WatchSingleRoomUseCase]
  new({required this._roomRepository});

  final IRoomRepository _roomRepository;

  @override
  Stream<AppResult<Room>> call(String params) {
    logDebug('start watching single room', extra: {'id': params});
    return _roomRepository.watchSingle(params);
  }
}
