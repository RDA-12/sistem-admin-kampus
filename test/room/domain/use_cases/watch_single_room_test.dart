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
  late WatchSingleRoomUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    roomRepositoryMock = getIt<IRoomRepository>();
    when(() => roomRepositoryMock.watchSingle('id'))
        .thenAnswer((_) => Stream.value(AppResult.success(room)));

    useCase = WatchSingleRoomUseCase(
      roomRepository: roomRepositoryMock,
    );
  });

  tearDown(() {
    reset(roomRepositoryMock);
  });

  group('WatchSingleRoomUseCase', () {
    test('emits correct Room', () async {
      final stream = useCase('id');

      expect(stream, emits(AppResult.success(room)));
    });

    test('emits failure when repo emits failure', () {
      when(() => roomRepositoryMock.watchSingle('id')).thenAnswer(
        (_) => Stream.value(
          AppFailure<Room>(exception: AppException.test()),
        ),
      );

      final stream = useCase('id');

      expect(
        stream,
        emits(AppFailure<Room>(exception: AppException.test())),
      );
    });
  });
}
