import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/room/domain/entities.dart';
import 'package:sistem_admin/room/domain/filters/room_filter.dart';
import 'package:sistem_admin/room/domain/use_cases/use_cases.dart';

/// Manage data on [Room]
abstract interface class IRoomRepository
    extends
        BaseRepository<Room, CreateRoomParams, UpdateRoomParams, RoomFilter>;
