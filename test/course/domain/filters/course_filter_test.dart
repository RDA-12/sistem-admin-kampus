import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/course/course.dart';

void main() {
  group('CourseFilter', () {
    test('supports value equality', () {
      const filterA = CourseFilter(programId: 'program_1');
      const filterB = CourseFilter(programId: 'program_1');
      const filterC = CourseFilter(programId: 'program_2');
      const filterD = CourseFilter();

      expect(filterA, equals(filterB));
      expect(filterA, isNot(equals(filterC)));
      expect(filterA, isNot(equals(filterD)));
      expect(filterA.props, ['program_1']);
      expect(filterD.props, [null]);
    });
  });
}
