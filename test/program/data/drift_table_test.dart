import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/program/program.dart';

void main() {
  group('ToDomainX', () {
    test('returns correct Program from ProgramDb', () {
      const expected = Program(
        id: 'id',
        facultyId: 'faculty_1',
        name: 'name',
      );

      final result = ProgramDb(
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
      'returns correct ProgramsDriftCompanion from UpdateProgramParams',
      () {
        const expected = ProgramsDriftCompanion(
          name: Value('new name'),
        );

        final result = const UpdateProgramParams(
          Program(id: 'id', facultyId: 'faculty_1', name: 'name'),
          name: 'new name',
        ).toCompanion();

        expect(result, expected);

        final result2 = const UpdateProgramParams(
          Program(id: 'id', facultyId: 'faculty_1', name: 'name'),
          name: null,
        ).toCompanion();

        expect(result2, const ProgramsDriftCompanion());
      },
    );
  });
}
