import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/room/room.dart';

void main() {
  group('ToDomainX', () {
    test('returns correct Room from RoomDb', () {
      const expected = Room(
        id: 'id',
        facultyId: 'faculty_1',
        name: 'name',
      );

      final result = RoomDb(
        id: 'id',
        facultyId: 'faculty_1',
        name: 'name',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(result.toDomain(), expected);
    });
  });

  group('ToCompanionX', () {
    test(
      'returns correct RoomsDriftCompanion from UpdateRoomParams',
      () {
        const expected = RoomsDriftCompanion(
          name: Value('new name'),
          facultyId: Value('faculty_2'),
        );

        final result = const UpdateRoomParams(
          Room(id: 'id', facultyId: 'faculty_1', name: 'name'),
          name: 'new name',
          facultyId: 'faculty_2',
        ).toCompanion();

        expect(result, expected);

        final result2 = const UpdateRoomParams(
          Room(id: 'id', facultyId: 'faculty_1', name: 'name'),
        ).toCompanion();

        expect(result2, const RoomsDriftCompanion());
      },
    );
  });
}
