import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

void main() {
  group('CourseScheduleEventDetail', () {
    test(
      'equal on cohortId, courseId, programId, lecturerId, and roomId',
      () {
        const testObj = CourseScheduleEventDetail(
          cohortId: 'cohort_1',
          courseId: 'course_1',
          programId: 'program_1',
          lecturerId: 'lecturer_1',
          roomId: 'room_1',
        );
        const a = CourseScheduleEventDetail(
          cohortId: 'cohort_1',
          courseId: 'course_1',
          programId: 'program_1',
          lecturerId: 'lecturer_1',
          roomId: 'room_1',
        );
        const b = CourseScheduleEventDetail(
          cohortId: 'cohort_2',
          courseId: 'course_1',
          programId: 'program_1',
          lecturerId: 'lecturer_1',
          roomId: 'room_1',
        );
        const c = CourseScheduleEventDetail(
          cohortId: 'cohort_1',
          courseId: 'course_2',
          programId: 'program_1',
          lecturerId: 'lecturer_1',
          roomId: 'room_1',
        );
        const d = CourseScheduleEventDetail(
          cohortId: 'cohort_1',
          courseId: 'course_1',
          programId: 'program_2',
          lecturerId: 'lecturer_1',
          roomId: 'room_1',
        );
        const e = CourseScheduleEventDetail(
          cohortId: 'cohort_1',
          courseId: 'course_1',
          programId: 'program_1',
          lecturerId: 'lecturer_2',
          roomId: 'room_1',
        );
        const f = CourseScheduleEventDetail(
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
      },
    );
  });

  group('CourseScheduleEvent', () {
    final start = EventDateTime(
      date: DateTime(2025, 9),
      time: const Time(hour: 8, minute: 0),
    );
    final end = EventDateTime(
      date: DateTime(2025, 9),
      time: const Time(hour: 10, minute: 0),
    );
    const detail = CourseScheduleEventDetail(
      cohortId: 'cohort_1',
      courseId: 'course_1',
      programId: 'program_1',
      lecturerId: 'lecturer_1',
      roomId: 'room_1',
    );

    test('always has type lectures', () {
      final event = CourseScheduleEvent(
        id: 'id',
        academicYearId: 'year_1',
        name: 'Kuliah Pemrograman Web',
        start: start,
        end: end,
        courseDetail: detail,
      );

      expect(event.type, AcademicCalendarEventType.lectures);
    });

    test(
      'equal on id, academicYearId, name, start, end, recurrence, '
      'and courseDetail',
      () {
        final testObj = CourseScheduleEvent(
          id: 'id',
          academicYearId: 'year_1',
          name: 'Kuliah Pemrograman Web',
          start: start,
          end: end,
          courseDetail: detail,
        );
        final a = CourseScheduleEvent(
          id: 'id',
          academicYearId: 'year_1',
          name: 'Kuliah Pemrograman Web',
          start: start,
          end: end,
          courseDetail: detail,
        );
        final b = CourseScheduleEvent(
          id: 'id B',
          academicYearId: 'year_1',
          name: 'Kuliah Pemrograman Web',
          start: start,
          end: end,
          courseDetail: detail,
        );
        final c = CourseScheduleEvent(
          id: 'id',
          academicYearId: 'year_2',
          name: 'Kuliah Pemrograman Web',
          start: start,
          end: end,
          courseDetail: detail,
        );
        final d = CourseScheduleEvent(
          id: 'id',
          academicYearId: 'year_1',
          name: 'Kuliah Basis Data',
          start: start,
          end: end,
          courseDetail: detail,
        );
        final e = CourseScheduleEvent(
          id: 'id',
          academicYearId: 'year_1',
          name: 'Kuliah Pemrograman Web',
          start: EventDateTime(
            date: DateTime(2025, 9, 2),
            time: const Time(hour: 8, minute: 0),
          ),
          end: end,
          courseDetail: detail,
        );
        final f = CourseScheduleEvent(
          id: 'id',
          academicYearId: 'year_1',
          name: 'Kuliah Pemrograman Web',
          start: start,
          end: EventDateTime(
            date: DateTime(2025, 9),
            time: const Time(hour: 12, minute: 0),
          ),
          courseDetail: detail,
        );
        final g = CourseScheduleEvent(
          id: 'id',
          academicYearId: 'year_1',
          name: 'Kuliah Pemrograman Web',
          start: start,
          end: end,
          courseDetail: detail,
        );
        final h = CourseScheduleEvent(
          id: 'id',
          academicYearId: 'year_1',
          name: 'Kuliah Pemrograman Web',
          start: start,
          end: end,
          courseDetail: const CourseScheduleEventDetail(
            cohortId: 'cohort_2',
            courseId: 'course_1',
            programId: 'program_1',
            lecturerId: 'lecturer_1',
            roomId: 'room_1',
          ),
        );

        expect(testObj, equals(a));
        expect(testObj, isNot(equals(b)));
        expect(testObj, isNot(equals(c)));
        expect(testObj, isNot(equals(d)));
        expect(testObj, isNot(equals(e)));
        expect(testObj, isNot(equals(f)));
        expect(testObj, isNot(equals(g)));
        expect(testObj, isNot(equals(h)));
      },
    );
  });
}
