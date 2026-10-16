import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/room/room.dart';

import '../../../common/di_mocks.dart';

void main() {
  const room = Room(
    id: 'id',
    facultyId: 'faculty_1',
    name: 'name',
  );
  const params = UpdateRoomParams(
    room,
    name: 'name 2',
    facultyId: 'faculty_2',
  );
  late IRoomRepository roomRepositoryMock;
  late UpdateRoomUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    roomRepositoryMock = getIt<IRoomRepository>();
    when(() => roomRepositoryMock.update(room.id, args: params))
        .thenAnswer((_) async => AppResult.success(room));

    useCase = UpdateRoomUseCase(
      roomRepository: roomRepositoryMock,
    );
  });

  tearDown(() {
    reset(roomRepositoryMock);
  });

  group('UpdateRoomUseCase', () {
    test('returns failure when RoomRepository.update fails', () async {
      when(() => roomRepositoryMock.update(room.id, args: params)).thenAnswer(
        (_) async => AppResult<Room>.failure(
          AppException.test(),
        ),
      );

      final result = await useCase(params);

      expect(
        result,
        isA<AppFailure<Room>>().having(
          (e) => e.exception,
          'exception',
          AppException.test(),
        ),
      );
    });

    test('returns correct Room when all operations success', () async {
      final result = await useCase(params);

      expect(result, AppResult.success(room));
      verify(() => roomRepositoryMock.update(room.id, args: params)).called(1);
    });
  });
}
