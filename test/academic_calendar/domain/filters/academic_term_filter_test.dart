import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';

void main() {
  group('AcademicTermFilter', () {
    test('supports value equality', () {
      const filterA = AcademicTermFilter(academicYearId: 'year_1');
      const filterB = AcademicTermFilter(academicYearId: 'year_1');
      const filterC = AcademicTermFilter(academicYearId: 'year_2');
      const filterD = AcademicTermFilter();

      expect(filterA, equals(filterB));
      expect(filterA, isNot(equals(filterC)));
      expect(filterA, isNot(equals(filterD)));
      expect(filterA.props, ['year_1']);
      expect(filterD.props, [null]);
    });
  });
}
