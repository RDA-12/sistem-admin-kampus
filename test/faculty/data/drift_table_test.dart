import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/faculty.dart';

void main() {
  group('ToDomainX', () {
    test('returns correct Faculty from FacultyDb', () {
      const expected = Faculty(id: 'id', name: 'name');

      final result = FacultyDb(
        id: 'id',
        name: 'name',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(result.toDomain(), expected);
    });
  });

  group('ToCompanionX', () {
    test(
      'returns correct FacultiesDriftCompanion from UpdateFacultyParams',
      () {
        const expected = FacultiesDriftCompanion(
          name: Value('new name'),
        );

        final result = const UpdateFacultyParams(
          Faculty(id: 'id', name: 'name'),
          name: 'new name',
        ).toCompanion();

        expect(result, expected);

        final result2 = const UpdateFacultyParams(
          Faculty(id: 'id', name: 'name'),
          name: null,
        ).toCompanion();

        expect(result2, const FacultiesDriftCompanion());
      },
    );
  });
}
