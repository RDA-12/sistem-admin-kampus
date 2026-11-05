import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/program/program.dart';

void main() {
  group('ProgramFilter', () {
    test('supports value equality', () {
      const filterA = ProgramFilter(facultyId: 'faculty_1');
      const filterB = ProgramFilter(facultyId: 'faculty_1');
      const filterC = ProgramFilter(facultyId: 'faculty_2');
      const filterD = ProgramFilter();

      expect(filterA, equals(filterB));
      expect(filterA, isNot(equals(filterC)));
      expect(filterA, isNot(equals(filterD)));
      expect(filterA.props, ['faculty_1']);
      expect(filterD.props, [null]);
    });
  });
}
