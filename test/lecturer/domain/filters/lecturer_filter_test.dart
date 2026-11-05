import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';

void main() {
  group('LecturerFilter', () {
    test('supports value equality', () {
      const filterA = LecturerFilter(programId: 'program_1');
      const filterB = LecturerFilter(programId: 'program_1');
      const filterC = LecturerFilter(programId: 'program_2');
      const filterD = LecturerFilter();

      expect(filterA, equals(filterB));
      expect(filterA, isNot(equals(filterC)));
      expect(filterA, isNot(equals(filterD)));
      expect(filterA.props, ['program_1']);
      expect(filterD.props, [null]);
    });
  });
}
