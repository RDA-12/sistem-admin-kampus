import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/room/room.dart';

import '../../../common/di_mocks.dart';

void main() {
  const params = CreateRoomParams(
    facultyId: 'faculty_1',
    name: 'name',
  );
  const room = Room(
    id: 'id',
    facultyId: 'faculty_1',
    name: 'name',
  );
  late IRoomRepository roomRepositoryMock;
  late CreateRoomUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    roomRepositoryMock = getIt<IRoomRepository>();
    when(() => roomRepositoryMock.save(params))
        .thenAnswer((_) async => AppResult.success(room));

    useCase = CreateRoomUseCase(
      roomRepository: roomRepositoryMock,
    );
  });

  tearDown(() {
    reset(roomRepositoryMock);
  });

  group('CreateRoomUseCase', () {
    test('returns failure when RoomRepository.save fails', () async {
      when(() => roomRepositoryMock.save(params)).thenAnswer(
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
      verify(() => roomRepositoryMock.save(params)).called(1);
    });
  });
}
