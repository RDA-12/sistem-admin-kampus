import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/room/room.dart';

import '../../common/di_mocks.dart';
import '../../common/helper.dart';

void main() {
  const faculty = Faculty(id: 'faculty_1', name: 'Faculty 1');
  const createdRoom = Room(
    id: 'uid',
    facultyId: 'faculty_1',
    name: 'name',
  );
  final seededRooms = List.generate(
    5,
    (index) => Room(
      id: 'room_$index',
      facultyId: faculty.id,
      name: 'Room $index',
    ),
  );
  late RoomRepository repository;
  late UidGenerator uidGeneratorMock;
  late AppDriftDatabase database;

  setUpAll(initializeMockDependencies);

  setUp(() async {
    database = getIt<AppDriftDatabase>();
    await database
        .into(database.facultiesDrift)
        .insert(
          FacultiesDriftCompanion.insert(id: faculty.id, name: faculty.name),
        );
    for (final r in seededRooms) {
      await database
          .into(database.roomsDrift)
          .insert(
            RoomsDriftCompanion.insert(
              id: r.id,
              facultyId: r.facultyId,
              name: r.name,
            ),
          );
    }

    uidGeneratorMock = getIt<UidGenerator>();
    when(uidGeneratorMock.generate).thenReturn(createdRoom.id);

    repository = RoomRepository(
      db: database,
      uidGenerator: uidGeneratorMock,
    );
  });

  tearDown(() async {
    await database.delete(database.roomsDrift).go();
    await database.delete(database.facultiesDrift).go();
  });

  group('RoomRepository', () {
    group('save', () {
      const createArgs = CreateRoomParams(
        facultyId: 'faculty_1',
        name: 'name',
      );

      test('returns correct new room and save it', () async {
        final now = DateTime.now();
        await withClock(Clock.fixed(now), () async {
          final result = await repository.save(createArgs);

          expect(result, AppResult.success(createdRoom));

          final query = database.select(database.roomsDrift)
            ..where((tbl) => tbl.id.equals(createdRoom.id));
          final exists = await query.getSingleOrNull();
          expect(exists, isNotNull);
          expect(exists!.facultyId, createArgs.facultyId);
          expect(exists.name, createArgs.name);
          expect(exists.createdAt, now);
          expect(exists.updatedAt, now);
        });
      });

      test(
        'returns failure with roomAlreadyExists code '
        'when save room with existing name in same faculty',
        () async {
          await repository.save(createArgs);

          final result = await repository.save(createArgs);

          result.expectFailureWithCode(AppExceptionCode.roomAlreadyExists);
        },
      );

      test(
        'returns failure with internal code '
        'when unintended exception occurred',
        () async {
          whenCalling(Invocation.method(#save, null))
              .on(repository)
              .thenThrow(Exception());

          final result = await repository.save(createArgs);

          result.expectFailureWithCode(AppExceptionCode.internal);
        },
      );
    });

    group('delete', () {
      test('returns success and delete requested room', () async {
        final query = database.select(database.roomsDrift);
        final beforeDelete = await query.get();
        expect(beforeDelete.map((it) => it.toDomain()), seededRooms);

        final result = await repository.delete(seededRooms.first.id);

        expect(result, AppResult.success(null));

        final afterDelete = await query.get();
        expect(
          afterDelete.map((it) => it.toDomain()),
          seededRooms.sublist(1),
        );
      });

      test('returns success when deleting non existing room', () async {
        final result = await repository.delete(createdRoom.id);

        expect(result, AppResult.success(null));
      });

      test(
        'returns failure with internal code '
        'when unintended exception occurred',
        () async {
          whenCalling(Invocation.method(#delete, null))
              .on(repository)
              .thenThrow(Exception());

          final result = await repository.delete(createdRoom.id);

          result.expectFailureWithCode(AppExceptionCode.internal);
        },
      );
    });

    group('watch', () {
      test('emits correct rooms', () async {
        final stream = repository.watch();

        expect(stream, emits(AppResult.success(seededRooms)));
      });

      test(
        'emits failure with internal code when unintended exception occurred',
        () async {
          whenCalling(Invocation.method(#watch, null))
              .on(repository)
              .thenThrow(Exception());

          final stream = repository.watch();

          expect(
            stream,
            emits(
              isA<AppFailure<List<Room>>>().having(
                (e) => e.exception.code,
                'exception.code',
                AppExceptionCode.internal,
              ),
            ),
          );
        },
      );
    });

    group('watch with filter', () {
      test('emits correct rooms for the faculty', () async {
        final stream = repository.watch(RoomFilter(facultyId: faculty.id));

        expect(stream, emits(AppResult.success(seededRooms)));
      });

      test(
        'emits failure with internal code when unintended exception occurred',
        () async {
          whenCalling(Invocation.method(#watch, null))
              .on(repository)
              .thenThrow(Exception());

          final stream = repository.watch(RoomFilter(facultyId: faculty.id));

          expect(
            stream,
            emits(
              isA<AppFailure<List<Room>>>().having(
                (e) => e.exception.code,
                'exception.code',
                AppExceptionCode.internal,
              ),
            ),
          );
        },
      );
    });

    group('update', () {
      test('returns updated room and save changes in database', () async {
        final query = database.select(database.roomsDrift);
        final before = await query.get();
        expect(before.map((it) => it.toDomain()), seededRooms);

        const expectedUpdated = Room(
          id: 'room_0',
          facultyId: 'faculty_1',
          name: 'updated name',
        );

        final updated = await repository.update(
          seededRooms.first.id,
          args: const UpdateRoomParams(
            expectedUpdated,
            name: 'updated name',
          ),
        );

        expect(updated, AppResult.success(expectedUpdated));

        final after = await query.get();
        expect(after.map((it) => it.toDomain()), [
          expectedUpdated,
          ...seededRooms.sublist(1),
        ]);
      });

      test('returns failure with roomNotFound code '
          'when update non existing room', () async {
        final result = await repository.update(
          createdRoom.id,
          args: const UpdateRoomParams(createdRoom, name: 'new name'),
        );

        result.expectFailureWithCode(AppExceptionCode.roomNotFound);
      });

      test('returns failure with roomAlreadyExists code '
          'when update with existing name', () async {
        final result = await repository.update(
          seededRooms.first.id,
          args: UpdateRoomParams(
            createdRoom,
            name: seededRooms[1].name,
          ),
        );

        result.expectFailureWithCode(AppExceptionCode.roomAlreadyExists);
      });

      test('returns failure with internal code '
          'when unintended exception occurred', () async {
        whenCalling(Invocation.method(#update, null))
            .on(repository)
            .thenThrow(Exception());

        final result = await repository.update(
          seededRooms.first.id,
          args: UpdateRoomParams(seededRooms.first, name: 'new name'),
        );

        result.expectFailureWithCode(AppExceptionCode.internal);
      });
    });

    group('watchSingle', () {
      test('emits correct room when room exists', () {
        final result = repository.watchSingle(seededRooms.first.id);

        expect(result, emits(AppResult.success(seededRooms.first)));
      });

      test(
        'emits failure with roomNotFound code when room does not exist',
        () {
          final result = repository.watchSingle('not-exists');

          expect(
            result,
            emits(
              isA<AppFailure<Room>>().having(
                (e) => e.exception.code,
                'exception.code',
                AppExceptionCode.roomNotFound,
              ),
            ),
          );
        },
      );
    });
  });
}
