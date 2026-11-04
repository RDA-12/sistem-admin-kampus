import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

void main() {
  group('CourseSchedule', () {
    final start = DateTime(2025, 9, 8, 8);
    const duration = Duration(minutes: 100);

    final testObj = CourseSchedule(
      id: 'id_1',
      academicYearId: 'year_1',
      termId: 'term_1',
      name: 'Pemrograman Web',
      start: start,
      duration: duration,
      cohortId: 'cohort_1',
      courseId: 'course_1',
      programId: 'program_1',
      lecturerId: 'lecturer_1',
      roomId: 'room_1',
    );

    test(
      'equal on id, academicYearId, termId, name, start, duration, '
      'cohortId, courseId, programId, lecturerId, roomId',
      () {
        final a = CourseSchedule(
          id: 'id_1',
          academicYearId: 'year_1',
          termId: 'term_1',
          name: 'Pemrograman Web',
          start: start,
          duration: duration,
          cohortId: 'cohort_1',
          courseId: 'course_1',
          programId: 'program_1',
          lecturerId: 'lecturer_1',
          roomId: 'room_1',
        );
        final b = CourseSchedule(
          id: 'id_2',
          academicYearId: 'year_1',
          termId: 'term_1',
          name: 'Pemrograman Web',
          start: start,
          duration: duration,
          cohortId: 'cohort_1',
          courseId: 'course_1',
          programId: 'program_1',
          lecturerId: 'lecturer_1',
          roomId: 'room_1',
        );
        final c = CourseSchedule(
          id: 'id_1',
          academicYearId: 'year_2',
          termId: 'term_1',
          name: 'Pemrograman Web',
          start: start,
          duration: duration,
          cohortId: 'cohort_1',
          courseId: 'course_1',
          programId: 'program_1',
          lecturerId: 'lecturer_1',
          roomId: 'room_1',
        );
        final d = CourseSchedule(
          id: 'id_1',
          academicYearId: 'year_1',
          termId: 'term_2',
          name: 'Pemrograman Web',
          start: start,
          duration: duration,
          cohortId: 'cohort_1',
          courseId: 'course_1',
          programId: 'program_1',
          lecturerId: 'lecturer_1',
          roomId: 'room_1',
        );
        final e = CourseSchedule(
          id: 'id_1',
          academicYearId: 'year_1',
          termId: 'term_1',
          name: 'Basis Data',
          start: start,
          duration: duration,
          cohortId: 'cohort_1',
          courseId: 'course_1',
          programId: 'program_1',
          lecturerId: 'lecturer_1',
          roomId: 'room_1',
        );
        final f = CourseSchedule(
          id: 'id_1',
          academicYearId: 'year_1',
          termId: 'term_1',
          name: 'Pemrograman Web',
          start: DateTime(2025, 9, 9, 8),
          duration: duration,
          cohortId: 'cohort_1',
          courseId: 'course_1',
          programId: 'program_1',
          lecturerId: 'lecturer_1',
          roomId: 'room_1',
        );
        final g = CourseSchedule(
          id: 'id_1',
          academicYearId: 'year_1',
          termId: 'term_1',
          name: 'Pemrograman Web',
          start: start,
          duration: const Duration(minutes: 150),
          cohortId: 'cohort_1',
          courseId: 'course_1',
          programId: 'program_1',
          lecturerId: 'lecturer_1',
          roomId: 'room_1',
        );
        final h = CourseSchedule(
          id: 'id_1',
          academicYearId: 'year_1',
          termId: 'term_1',
          name: 'Pemrograman Web',
          start: start,
          duration: duration,
          cohortId: 'cohort_2',
          courseId: 'course_1',
          programId: 'program_1',
          lecturerId: 'lecturer_1',
          roomId: 'room_1',
        );
        final i = CourseSchedule(
          id: 'id_1',
          academicYearId: 'year_1',
          termId: 'term_1',
          name: 'Pemrograman Web',
          start: start,
          duration: duration,
          cohortId: 'cohort_1',
          courseId: 'course_2',
          programId: 'program_1',
          lecturerId: 'lecturer_1',
          roomId: 'room_1',
        );
        final j = CourseSchedule(
          id: 'id_1',
          academicYearId: 'year_1',
          termId: 'term_1',
          name: 'Pemrograman Web',
          start: start,
          duration: duration,
          cohortId: 'cohort_1',
          courseId: 'course_1',
          programId: 'program_2',
          lecturerId: 'lecturer_1',
          roomId: 'room_1',
        );
        final k = CourseSchedule(
          id: 'id_1',
          academicYearId: 'year_1',
          termId: 'term_1',
          name: 'Pemrograman Web',
          start: start,
          duration: duration,
          cohortId: 'cohort_1',
          courseId: 'course_1',
          programId: 'program_1',
          lecturerId: 'lecturer_2',
          roomId: 'room_1',
        );
        final l = CourseSchedule(
          id: 'id_1',
          academicYearId: 'year_1',
          termId: 'term_1',
          name: 'Pemrograman Web',
          start: start,
          duration: duration,
          cohortId: 'cohort_1',
          courseId: 'course_1',
          programId: 'program_1',
          lecturerId: 'lecturer_1',
          roomId: 'room_2',
        );

        expect(testObj, equals(a));
        expect(testObj, isNot(equals(b)));
        expect(testObj, isNot(equals(c)));
        expect(testObj, isNot(equals(d)));
        expect(testObj, isNot(equals(e)));
        expect(testObj, isNot(equals(f)));
        expect(testObj, isNot(equals(g)));
        expect(testObj, isNot(equals(h)));
        expect(testObj, isNot(equals(i)));
        expect(testObj, isNot(equals(j)));
        expect(testObj, isNot(equals(k)));
        expect(testObj, isNot(equals(l)));
      },
    );

    group('overlaps', () {
      test('returns empty list when start is before schedule start', () {
        final result = testObj.overlaps(
          start: DateTime(2025, 9, 8, 7, 59),
          cohortId: testObj.cohortId,
          courseId: testObj.courseId,
          lecturerId: testObj.lecturerId,
          roomId: testObj.roomId,
        );

        expect(result, isEmpty);
      });

      test('returns empty list when start is at or after schedule end', () {
        final resultAtEnd = testObj.overlaps(
          start: DateTime(2025, 9, 8, 9, 40),
          cohortId: testObj.cohortId,
          courseId: testObj.courseId,
          lecturerId: testObj.lecturerId,
          roomId: testObj.roomId,
        );
        final resultAfterEnd = testObj.overlaps(
          start: DateTime(2025, 9, 8, 10),
          cohortId: testObj.cohortId,
          courseId: testObj.courseId,
          lecturerId: testObj.lecturerId,
          roomId: testObj.roomId,
        );

        expect(resultAtEnd, isEmpty);
        expect(resultAfterEnd, isEmpty);
      });

      test('returns empty list when time overlaps but no resources match', () {
        final result = testObj.overlaps(
          start: DateTime(2025, 9, 8, 8, 30),
          cohortId: 'different_cohort',
          courseId: 'different_course',
          lecturerId: 'different_lecturer',
          roomId: 'different_room',
        );

        expect(result, isEmpty);
      });

      test(
        'returns [ruangan] when only roomId matches during time overlap',
        () {
          final result = testObj.overlaps(
            start: start,
            cohortId: 'different_cohort',
            courseId: 'different_course',
            lecturerId: 'different_lecturer',
            roomId: testObj.roomId,
          );

          expect(result, ['ruangan']);
        },
      );

      test(
        'returns [mata kuliah] when only courseId matches during time overlap',
        () {
          final result = testObj.overlaps(
            start: DateTime(2025, 9, 8, 8, 30),
            cohortId: 'different_cohort',
            courseId: testObj.courseId,
            lecturerId: 'different_lecturer',
            roomId: 'different_room',
          );

          expect(result, ['mata kuliah']);
        },
      );

      test(
        'returns [dosen] when only lecturerId matches during time overlap',
        () {
          final result = testObj.overlaps(
            start: start,
            cohortId: 'different_cohort',
            courseId: 'different_course',
            lecturerId: testObj.lecturerId,
            roomId: 'different_room',
          );

          expect(result, ['dosen']);
        },
      );

      test(
        'returns [angkatan] when only cohortId matches during time overlap',
        () {
          final result = testObj.overlaps(
            start: start,
            cohortId: testObj.cohortId,
            courseId: 'different_course',
            lecturerId: 'different_lecturer',
            roomId: 'different_room',
          );

          expect(result, ['angkatan']);
        },
      );

      test(
        'returns all collision reasons when all resources match at same start',
        () {
          final result = testObj.overlaps(
            start: start,
            cohortId: testObj.cohortId,
            courseId: testObj.courseId,
            lecturerId: testObj.lecturerId,
            roomId: testObj.roomId,
          );

          expect(result, ['ruangan', 'mata kuliah', 'dosen', 'angkatan']);
        },
      );
    });
  });
}
