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
  late WatchRoomsByFacultyUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    roomRepositoryMock = getIt<IRoomRepository>();
    when(() => roomRepositoryMock.watchByFaculty('faculty_1'))
        .thenAnswer((_) => Stream.value(AppResult.success(rooms)));

    useCase = WatchRoomsByFacultyUseCase(
      roomRepository: roomRepositoryMock,
    );
  });

  tearDown(() {
    reset(roomRepositoryMock);
  });

  group('WatchRoomsByFacultyUseCase', () {
    test('emits correct list of Room for the faculty', () async {
      final stream = useCase('faculty_1');

      expect(stream, emits(AppResult.success(rooms)));
    });

    test('emits failure when repo emits failure', () {
      when(() => roomRepositoryMock.watchByFaculty('faculty_1')).thenAnswer(
        (_) => Stream.value(
          AppFailure<List<Room>>(exception: AppException.test()),
        ),
      );

      final stream = useCase('faculty_1');

      expect(
        stream,
        emits(AppFailure<List<Room>>(exception: AppException.test())),
      );
    });
  });
}
