import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

void main() {
  group('CourseCalendar', () {
    final year = AcademicYear(
      id: 'year_1',
      name: '2025/2026',
      startDate: DateTime(2025, 9),
      endDate: DateTime(2026, 8, 31),
    );
    final academicCalendar = AcademicCalendar(year: year);

    final schedule1 = CourseSchedule(
      id: 'schedule_1',
      academicYearId: 'year_1',
      termId: 'term_1',
      programId: 'program_1',
      name: 'Pemrograman Web',
      start: DateTime(2025, 9, 8, 8),
      duration: const Duration(minutes: 100),
      cohortId: 'cohort_1',
      courseId: 'course_1',
      lecturerId: 'lecturer_1',
      roomId: 'room_1',
    );

    final schedule2 = CourseSchedule(
      id: 'schedule_2',
      academicYearId: 'year_1',
      termId: 'term_1',
      programId: 'program_1',
      name: 'Basis Data',
      start: DateTime(2025, 9, 8, 10),
      duration: const Duration(minutes: 100),
      cohortId: 'cohort_1',
      courseId: 'course_2',
      lecturerId: 'lecturer_2',
      roomId: 'room_2',
    );

    test('equal on academicCalendar and schedules', () {
      final calendar1 = CourseCalendar(
        academicCalendar: academicCalendar,
        schedules: [schedule1],
      );
      final calendar2 = CourseCalendar(
        academicCalendar: academicCalendar,
        schedules: [schedule1],
      );
      final differentCalendar = CourseCalendar(
        academicCalendar: academicCalendar,
        schedules: [schedule2],
      );

      expect(calendar1, equals(calendar2));
      expect(calendar1, isNot(equals(differentCalendar)));
    });

    group('canAddSchedule', () {
      test('returns success when schedules list is empty', () {
        final calendar = CourseCalendar(
          academicCalendar: academicCalendar,
          schedules: const [],
        );

        final result = calendar.canAddSchedule(
          start: schedule1.start,
          cohortId: schedule1.cohortId,
          courseId: schedule1.courseId,
          lecturerId: schedule1.lecturerId,
          roomId: schedule1.roomId,
        );

        expect(result, AppResult.success(null));
      });

      test(
        'returns success when new schedule does not collide with existing',
        () {
          final calendar = CourseCalendar(
            academicCalendar: academicCalendar,
            schedules: [schedule1],
          );

          final result = calendar.canAddSchedule(
            start: schedule2.start,
            cohortId: schedule2.cohortId,
            courseId: schedule2.courseId,
            lecturerId: schedule2.lecturerId,
            roomId: schedule2.roomId,
          );

          expect(result, AppResult.success(null));
        },
      );

      test(
        'returns failure with CourseScheduleCollisionException on collision',
        () {
          final calendar = CourseCalendar(
            academicCalendar: academicCalendar,
            schedules: [schedule1],
          );

          final result = calendar.canAddSchedule(
            start: DateTime(2025, 9, 8, 8, 30),
            cohortId: 'cohort_other',
            courseId: 'course_other',
            lecturerId: 'lecturer_other',
            roomId: schedule1.roomId,
          );

          expect(
            result,
            isA<AppFailure<Null>>().having(
              (e) => e.exception,
              'exception',
              isA<CourseScheduleCollisionException>().having(
                (e) => e.details,
                'details',
                [
                  CourseScheduleCollisionDetail(
                    start: schedule1.start,
                    duration: schedule1.duration,
                    cohortId: schedule1.cohortId,
                    courseId: schedule1.courseId,
                    lecturerId: schedule1.lecturerId,
                    roomId: schedule1.roomId,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });

    group('canUpdateSchedule', () {
      test(
        'returns success when updating only existing schedule '
        'without collision',
        () {
          final calendar = CourseCalendar(
            academicCalendar: academicCalendar,
            schedules: [schedule1, schedule2],
          );

          final result = calendar.canUpdateSchedule(
            scheduleId: schedule1.id,
            start: schedule1.start,
            cohortId: schedule1.cohortId,
            courseId: schedule1.courseId,
            lecturerId: schedule1.lecturerId,
            roomId: schedule1.roomId,
          );

          expect(result, AppResult.success(null));
        },
      );

      test(
        'returns failure when updated schedule collides with another schedule',
        () {
          final calendar = CourseCalendar(
            academicCalendar: academicCalendar,
            schedules: [schedule1, schedule2],
          );

          // updating schedule2 to overlap with schedule1's time and roomId
          final result = calendar.canUpdateSchedule(
            scheduleId: schedule2.id,
            start: schedule1.start,
            cohortId: schedule2.cohortId,
            courseId: schedule2.courseId,
            lecturerId: schedule2.lecturerId,
            roomId: schedule1.roomId,
          );

          expect(
            result,
            isA<AppFailure<Null>>().having(
              (e) => e.exception,
              'exception',
              isA<CourseScheduleCollisionException>().having(
                (e) => e.details,
                'details',
                [
                  CourseScheduleCollisionDetail(
                    start: schedule1.start,
                    duration: schedule1.duration,
                    cohortId: schedule1.cohortId,
                    courseId: schedule1.courseId,
                    lecturerId: schedule1.lecturerId,
                    roomId: schedule1.roomId,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  });
}
