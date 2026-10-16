import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/room/room.dart';

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
    facultyId: 'faculty_1',
    name: 'Room $index',
  ),
);
const roomMock = Room(
  id: 'id',
  facultyId: 'faculty_1',
  name: 'Room',
);
