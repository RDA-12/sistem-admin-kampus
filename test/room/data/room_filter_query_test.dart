import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/room/room.dart';

void main() {
  late AppDriftDatabase database;

  setUp(() {
    database = AppDriftDatabase.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
  });

  tearDown(() async {
    await database.close();
  });

  group('RoomFilterX', () {
    const faculty1Id = 'faculty_1';
    const faculty2Id = 'faculty_2';

    setUp(() async {
      await database.into(database.facultiesDrift).insert(
        FacultiesDriftCompanion.insert(
          id: faculty1Id,
          name: 'Faculty 1',
        ),
      );
      await database.into(database.facultiesDrift).insert(
        FacultiesDriftCompanion.insert(
          id: faculty2Id,
          name: 'Faculty 2',
        ),
      );
      await database.into(database.roomsDrift).insert(
        RoomsDriftCompanion.insert(
          id: 'room_1',
          facultyId: faculty1Id,
          name: 'Room 1',
        ),
      );
      await database.into(database.roomsDrift).insert(
        RoomsDriftCompanion.insert(
          id: 'room_2',
          facultyId: faculty2Id,
          name: 'Room 2',
        ),
      );
    });

    test('applies where clause when facultyId is provided', () async {
      final initialQuery = database.select(database.roomsDrift);
      final query = const RoomFilter(facultyId: faculty1Id).apply(initialQuery);
      final result = await query.get();

      expect(result.length, 1);
      expect(result.first.id, 'room_1');
      expect(result.first.facultyId, faculty1Id);
    });

    test('returns unmodified query when facultyId is null', () async {
      final initialQuery = database.select(database.roomsDrift);
      final query = const RoomFilter().apply(initialQuery);
      final result = await query.get();

      expect(result.length, 2);
      expect(result.map((e) => e.id), containsAll(['room_1', 'room_2']));
    });
  });
}
