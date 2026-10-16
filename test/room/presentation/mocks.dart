import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/room/room.dart';

@LazySingleton(as: RoomsBloc, env: [Environment.test])
class MockRoomsBloc extends Mock implements RoomsBloc;

@LazySingleton(as: RoomDetailBloc, env: [Environment.test])
class MockRoomDetailBloc extends Mock implements RoomDetailBloc;

@LazySingleton(as: RoomMutationBloc, env: [Environment.test])
class MockRoomMutationBloc extends Mock implements RoomMutationBloc;
