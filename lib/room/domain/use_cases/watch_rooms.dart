import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/room/domain/entities.dart';
import 'package:sistem_admin/room/domain/filters/room_filter.dart';
import 'package:sistem_admin/room/domain/repository.dart';

/// Use case to watch for [Room] data changes
@LazySingleton(env: [Environment.prod])
class WatchRoomsUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<RoomFilter?, List<Room>> {
  /// Creates new [WatchRoomsUseCase]
  new({required this._roomRepository});

  final IRoomRepository _roomRepository;

  @override
  Stream<AppResult<List<Room>>> call([RoomFilter? params]) {
    logDebug(
      'start watching rooms',
      extra: params != null ? {'filter': params} : null,
    );
    return _roomRepository.watch(params);
  }
}
