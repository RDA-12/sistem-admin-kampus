import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/course.dart';

void main() {
  group('ToDomainX', () {
    test('returns correct Course from CourseDb', () {
      const expected = Course(
        id: 'id',
        programId: 'program_1',
        code: 'CS101',
        name: 'Pemrograman Dasar',
        semester: 1,
      );

      final result = CourseDb(
        id: 'id',
        programId: 'program_1',
        code: 'CS101',
        name: 'Pemrograman Dasar',
        semester: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(result.toDomain(), expected);
    });
  });

  group('ToCompanionX', () {
    test(
      'returns correct CoursesDriftCompanion from UpdateCourseParams',
      () {
        const expected = CoursesDriftCompanion(
          code: Value('CS102'),
          name: Value('new name'),
          semester: Value(2),
        );

        final result = const UpdateCourseParams(
          Course(
            id: 'id',
            programId: 'program_1',
            code: 'CS101',
            name: 'name',
            semester: 1,
          ),
          code: 'CS102',
          name: 'new name',
          semester: 2,
        ).toCompanion();

        expect(result, expected);

        final result2 = const UpdateCourseParams(
          Course(
            id: 'id',
            programId: 'program_1',
            code: 'CS101',
            name: 'name',
            semester: 1,
          ),
        ).toCompanion();

        expect(result2, const CoursesDriftCompanion());
      },
    );
  });
}
