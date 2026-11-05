import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/room/room.dart';

import '../../../common/di_mocks.dart';

void main() {
  final rooms = List.generate(
    5,
    (index) => Room(
      id: '$index',
      facultyId: 'faculty_1',
      name: 'Room $index',
    ),
  );
  late IRoomRepository roomRepositoryMock;
  late WatchRoomsUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    roomRepositoryMock = getIt<IRoomRepository>();
    when(roomRepositoryMock.watch)
        .thenAnswer((_) => Stream.value(AppResult.success(rooms)));

    useCase = WatchRoomsUseCase(
      roomRepository: roomRepositoryMock,
    );
  });

  tearDown(() {
    reset(roomRepositoryMock);
  });

  group('WatchRoomsUseCase', () {
    test('emits correct list of Room when no filter provided', () async {
      final stream = useCase();

      expect(stream, emits(AppResult.success(rooms)));
    });

    test('emits correct list of Room when filter provided', () async {
      const filter = RoomFilter(facultyId: 'faculty_1');
      when(() => roomRepositoryMock.watch(filter))
          .thenAnswer((_) => Stream.value(AppResult.success(rooms)));

      final stream = useCase(filter);

      expect(stream, emits(AppResult.success(rooms)));
    });

    test('emits failure when repo emits failure', () {
      when(roomRepositoryMock.watch).thenAnswer(
        (_) => Stream.value(
          AppFailure<List<Room>>(exception: AppException.test()),
        ),
      );

      final stream = useCase();

      expect(
        stream,
        emits(AppFailure<List<Room>>(exception: AppException.test())),
      );
    });
  });
}
