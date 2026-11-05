import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';

void main() {
  group('AcademicCalendarEventFilter', () {
    test('supports value equality', () {
      const filterA = AcademicCalendarEventFilter(academicYearId: 'year_1');
      const filterB = AcademicCalendarEventFilter(academicYearId: 'year_1');
      const filterC = AcademicCalendarEventFilter(academicYearId: 'year_2');
      const filterD = AcademicCalendarEventFilter();

      expect(filterA, equals(filterB));
      expect(filterA, isNot(equals(filterC)));
      expect(filterA, isNot(equals(filterD)));
      expect(filterA.props, ['year_1']);
      expect(filterD.props, [null]);
    });
  });
}
