import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/room/domain/entities.dart';
import 'package:sistem_admin/room/domain/repository.dart';

/// Use case to watch for [Room] data changes
@LazySingleton(env: [Environment.prod])
class WatchRoomsUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<Null, List<Room>> {
  /// Creates new [WatchRoomsUseCase]
  new({required this._roomRepository});

  final IRoomRepository _roomRepository;

  @override
  Stream<AppResult<List<Room>>> call(Null params) {
    logDebug('start watching rooms');
    return _roomRepository.watch();
  }
}
