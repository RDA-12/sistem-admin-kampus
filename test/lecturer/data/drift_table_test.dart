import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';

void main() {
  group('ToDomainX', () {
    test('returns correct Lecturer from LecturerDb', () {
      const expected = Lecturer(
        id: 'id',
        programId: 'program_1',
        name: 'name',
        pangkatGolongan: 'III/a',
      );

      final result = LecturerDb(
        id: 'id',
        programId: 'program_1',
        name: 'name',
        pangkatGolongan: 'III/a',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(result.toDomain(), expected);
    });
  });

  group('ToCompanionX', () {
    test(
      'returns correct LecturersDriftCompanion from UpdateLecturerParams',
      () {
        const expected = LecturersDriftCompanion(
          name: Value('new name'),
          pangkatGolongan: Value('IV/a'),
        );

        final result = const UpdateLecturerParams(
          Lecturer(
            id: 'id',
            programId: 'program_1',
            name: 'name',
            pangkatGolongan: 'III/a',
          ),
          name: 'new name',
          pangkatGolongan: 'IV/a',
        ).toCompanion();

        expect(result, expected);

        final result2 = const UpdateLecturerParams(
          Lecturer(
            id: 'id',
            programId: 'program_1',
            name: 'name',
            pangkatGolongan: 'III/a',
          ),
        ).toCompanion();

        expect(result2, const LecturersDriftCompanion());
      },
    );
  });
}
