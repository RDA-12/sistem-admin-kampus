import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/room/room.dart';

import '../../faculty/domain/mocks.dart';

@LazySingleton(as: IRoomRepository, env: [Environment.test])
class MockRoomRepository extends Mock implements IRoomRepository;

@LazySingleton(as: WatchRoomsUseCase, env: [Environment.test])
class MockWatchRoomsUseCase extends Mock implements WatchRoomsUseCase;

@LazySingleton(as: WatchRoomsByFacultyUseCase, env: [Environment.test])
class MockWatchRoomsByFacultyUseCase extends Mock
    implements WatchRoomsByFacultyUseCase;

@LazySingleton(as: WatchSingleRoomUseCase, env: [Environment.test])
class MockWatchSingleRoomUseCase extends Mock implements WatchSingleRoomUseCase;

@LazySingleton(as: CreateRoomUseCase, env: [Environment.test])
class MockCreateRoomUseCase extends Mock implements CreateRoomUseCase;

@LazySingleton(as: UpdateRoomUseCase, env: [Environment.test])
class MockUpdateRoomUseCase extends Mock implements UpdateRoomUseCase;

@LazySingleton(as: DeleteRoomUseCase, env: [Environment.test])
class MockDeleteRoomUseCase extends Mock implements DeleteRoomUseCase;

final roomsMock = List<Room>.generate(
  5,
  (index) => Room(
    id: '$index',
    facultyId: facultyMock.id,
    name: 'Room $index',
  ),
);
const roomMock = Room(
  id: 'id',
  facultyId: 'id',
  name: 'Room',
);
final List<RoomUI> roomsUIMock = roomsMock
    .map(
      (it) => RoomUI(
        id: it.id,
        facultyId: facultyMock.id,
        name: it.name,
        faculty: facultyMock,
      ),
    )
    .toList();
final RoomUI roomUIMock = roomsUIMock.first;
