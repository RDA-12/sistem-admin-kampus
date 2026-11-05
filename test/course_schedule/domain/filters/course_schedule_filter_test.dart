import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

void main() {
  group('CourseScheduleFilter', () {
    test('supports value equality', () {
      const filterA = CourseScheduleFilter(
        academicYearId: 'year_1',
        cohortId: 'cohort_1',
        termId: 'term_1',
        programId: 'program_1',
      );
      const filterB = CourseScheduleFilter(
        academicYearId: 'year_1',
        cohortId: 'cohort_1',
        termId: 'term_1',
        programId: 'program_1',
      );
      const filterDifferentYear = CourseScheduleFilter(
        academicYearId: 'year_2',
        cohortId: 'cohort_1',
        termId: 'term_1',
        programId: 'program_1',
      );
      const filterDifferentCohort = CourseScheduleFilter(
        academicYearId: 'year_1',
        cohortId: 'cohort_2',
        termId: 'term_1',
        programId: 'program_1',
      );
      const filterDifferentTerm = CourseScheduleFilter(
        academicYearId: 'year_1',
        cohortId: 'cohort_1',
        termId: 'term_2',
        programId: 'program_1',
      );
      const filterDifferentProgram = CourseScheduleFilter(
        academicYearId: 'year_1',
        cohortId: 'cohort_1',
        termId: 'term_1',
        programId: 'program_2',
      );
      const filterEmpty = CourseScheduleFilter();

      expect(filterA, equals(filterB));
      expect(filterA, isNot(equals(filterDifferentYear)));
      expect(filterA, isNot(equals(filterDifferentCohort)));
      expect(filterA, isNot(equals(filterDifferentTerm)));
      expect(filterA, isNot(equals(filterDifferentProgram)));
      expect(filterA, isNot(equals(filterEmpty)));
      expect(
        filterA.props,
        equals(['year_1', 'cohort_1', 'term_1', 'program_1']),
      );
      expect(filterEmpty.props, equals([null, null, null, null]));
    });
  });
}
