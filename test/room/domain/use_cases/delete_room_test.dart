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
  late IRoomRepository roomRepositoryMock;
  late DeleteRoomUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    roomRepositoryMock = getIt<IRoomRepository>();
    when(() => roomRepositoryMock.delete(room.id))
        .thenAnswer((_) async => AppResult.success(null));

    useCase = DeleteRoomUseCase(
      roomRepository: roomRepositoryMock,
    );
  });

  tearDown(() {
    reset(roomRepositoryMock);
  });

  group('DeleteRoomUseCase', () {
    test('returns failure when RoomRepository.delete fails', () async {
      when(() => roomRepositoryMock.delete(room.id)).thenAnswer(
        (_) async => AppResult<Null>.failure(
          AppException.test(),
        ),
      );

      final result = await useCase(room);

      expect(
        result,
        isA<AppFailure<Null>>().having(
          (e) => e.exception,
          'exception',
          AppException.test(),
        ),
      );
    });

    test('returns correct null when all operations success', () async {
      final result = await useCase(room);

      expect(result, AppResult.success(null));
      verify(() => roomRepositoryMock.delete(room.id)).called(1);
    });
  });
}
