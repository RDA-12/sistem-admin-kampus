import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/room/domain/entities.dart';
import 'package:sistem_admin/room/domain/filters/room_filter.dart';
import 'package:sistem_admin/room/domain/repository.dart';

/// Use case to watch for [Room] data changes for specific faculty
@LazySingleton(env: [Environment.prod])
class WatchRoomsByFacultyUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<String, List<Room>> {
  /// Creates new [WatchRoomsByFacultyUseCase]
  new({required this._roomRepository});

  final IRoomRepository _roomRepository;

  @override
  Stream<AppResult<List<Room>>> call(String params) {
    logDebug(
      'start watching rooms by faculty',
      extra: {'facultyId': params},
    );
    return _roomRepository.watch(RoomFilter(facultyId: params));
  }
}
