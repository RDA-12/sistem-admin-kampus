import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';

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

  group('LecturerFilterX', () {
    const program1Id = 'program_1';
    const program2Id = 'program_2';

    setUp(() async {
      await database.into(database.facultiesDrift).insert(
        FacultiesDriftCompanion.insert(
          id: 'faculty_1',
          name: 'Faculty 1',
        ),
      );
      await database.into(database.programsDrift).insert(
        ProgramsDriftCompanion.insert(
          id: program1Id,
          facultyId: 'faculty_1',
          name: 'Program 1',
        ),
      );
      await database.into(database.programsDrift).insert(
        ProgramsDriftCompanion.insert(
          id: program2Id,
          facultyId: 'faculty_1',
          name: 'Program 2',
        ),
      );
      await database.into(database.lecturersDrift).insert(
        LecturersDriftCompanion.insert(
          id: 'lecturer_1',
          programId: program1Id,
          name: 'Lecturer 1',
          pangkatGolongan: 'III/a',
        ),
      );
      await database.into(database.lecturersDrift).insert(
        LecturersDriftCompanion.insert(
          id: 'lecturer_2',
          programId: program2Id,
          name: 'Lecturer 2',
          pangkatGolongan: 'III/b',
        ),
      );
    });

    test('applies where clause when programId is provided', () async {
      final initialQuery = database.select(database.lecturersDrift);
      final query =
          const LecturerFilter(programId: program1Id).apply(initialQuery);
      final result = await query.get();

      expect(result.length, 1);
      expect(result.first.id, 'lecturer_1');
      expect(result.first.programId, program1Id);
    });

    test('returns unmodified query when programId is null', () async {
      final initialQuery = database.select(database.lecturersDrift);
      final query = const LecturerFilter().apply(initialQuery);
      final result = await query.get();

      expect(result.length, 2);
      expect(
        result.map((e) => e.id),
        containsAll(['lecturer_1', 'lecturer_2']),
      );
    });
  });
}
