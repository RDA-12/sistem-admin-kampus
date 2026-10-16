import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/room/domain/entities.dart';
import 'package:sistem_admin/room/domain/use_cases/use_cases.dart';

/// Manage data on [Room]
abstract interface class IRoomRepository
    extends BaseRepository<Room, CreateRoomParams, UpdateRoomParams> {
  /// Watch for [Room] data changes for specific [facultyId]
  Stream<AppResult<List<Room>>> watchByFaculty(String facultyId);
}
