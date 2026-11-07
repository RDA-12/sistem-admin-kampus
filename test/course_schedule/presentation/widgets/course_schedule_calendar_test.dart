import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../../../academic_calendar/domain/mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    required CourseScheduleCalendarUI calendar,
    Size phoneSize = const Size(1200, 800),
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return CourseScheduleCalendar(
          calendar: calendar,
        );
      },
      phoneSize: phoneSize,
    );
  }

  Finder findCardPositioned(CourseScheduleUI schedule) {
    return find.ancestor(
      of: find.byWidgetPredicate(
        (w) => w is CourseScheduleCard && w.schedule == schedule,
      ),
      matching: find.byType(Positioned),
    );
  }

  group('CourseScheduleCalendar', () {
    group('Render', () {
      testWidgets('shows TableView', (tester) async {
        await pumpWidget(tester, calendar: courseScheduleCalendarUIMock);

        expect(find.byType(TableView), findsOneWidget);
      });

      testWidgets('shows time cells', (tester) async {
        await pumpWidget(tester, calendar: courseScheduleCalendarUIMock);

        expect(find.text('07:00'), findsOneWidget);
        expect(find.text('07:30'), findsOneWidget);
        expect(find.text('08:00'), findsOneWidget);
      });

      testWidgets('shows initial day headers and reveals more on scroll', (
        tester,
      ) async {
        await pumpWidget(tester, calendar: courseScheduleCalendarUIMock);

        // First days visible in viewport
        expect(find.text('Senin'), findsWidgets);
        expect(find.text('Selasa'), findsWidgets);

        // Scroll horizontally to bring later days into viewport
        await tester.drag(find.byType(TableView), const Offset(-800, 0));
        await tester.pumpAndSettle();

        expect(find.text('Kamis'), findsWidgets);
      });

      testWidgets('shows semester headers for all semesters in calendar', (
        tester,
      ) async {
        await pumpWidget(tester, calendar: courseScheduleCalendarUIMock);

        for (final semester in courseScheduleCalendarUIMock.listOfSemester) {
          expect(find.text('Semester $semester'), findsWidgets);
        }
      });

      testWidgets(
        'uses fallback of 1 semester when calendar has single semester',
        (tester) async {
          final singleSchedule = courseSchedulesUIMock.first;
          final calendarSingleSemester = CourseScheduleCalendarUI(
            academicCalendar: AcademicCalendar(year: academicYearMock),
            schedules: [singleSchedule],
          );

          await pumpWidget(tester, calendar: calendarSingleSemester);

          expect(find.text('Semester 1'), findsWidgets);
          expect(find.text('Semester 2'), findsNothing);
        },
      );

      testWidgets(
        'shows CourseScheduleCard for visible schedules',
        (tester) async {
          await pumpWidget(tester, calendar: courseScheduleCalendarUIMock);

          expect(find.byType(CourseScheduleCard), findsWidgets);
        },
      );

      testWidgets(
        'correctly positions CourseScheduleCard according to day, time, '
        'and duration',
        (tester) async {
          await pumpWidget(tester, calendar: courseScheduleCalendarUIMock);

          final targetSchedule = courseSchedulesUIMock.first;
          final finder = findCardPositioned(targetSchedule);

          expect(finder, findsWidgets);
          final positioned = tester.widgetList<Positioned>(finder).first;

          // Start: 08:00 (1 hour after 07:00 => 2 half-hours * 60 = 120.0)
          expect(positioned.top, 120.0);
          // Monday, Semester 1 (index 0) => left is 0.0
          expect(positioned.left, 0.0);
          // Credit: 3 * 50 = 150 mins / 30 mins * 60 = 300.0
          expect(positioned.height, 300.0);
          expect(positioned.width, isPositive);
        },
      );
    });

    group('Interactions', () {
      testWidgets('adjusts schedule top position on vertical scroll', (
        tester,
      ) async {
        await pumpWidget(tester, calendar: courseScheduleCalendarUIMock);

        final targetSchedule = courseSchedulesUIMock.first;
        final finder = findCardPositioned(targetSchedule);

        final initialPositioned = tester.widgetList<Positioned>(finder).first;
        expect(initialPositioned.top, 120.0);

        // Scroll down by 60 pixels
        await tester.drag(find.byType(TableView), const Offset(0, -60));
        await tester.pumpAndSettle();

        final updatedPositioned = tester.widgetList<Positioned>(finder).first;
        expect(updatedPositioned.top, lessThan(initialPositioned.top!));
      });

      testWidgets('adjusts schedule left position on horizontal scroll', (
        tester,
      ) async {
        await pumpWidget(tester, calendar: courseScheduleCalendarUIMock);

        final tuesdaySchedule = courseSchedulesUIMock[1];
        final finder = findCardPositioned(tuesdaySchedule);

        expect(finder, findsWidgets);
        final initialLeft = tester.widgetList<Positioned>(finder).first.left;

        // Scroll horizontally left by 50 pixels
        await tester.drag(find.byType(TableView), const Offset(-50, 0));
        await tester.pumpAndSettle();

        final updatedLeft = tester.widgetList<Positioned>(finder).first.left;
        expect(updatedLeft, lessThan(initialLeft!));
      });
    });

    group('Lifecycle', () {
      testWidgets('updates displayed schedules when calendar changes', (
        tester,
      ) async {
        final initialCalendar = CourseScheduleCalendarUI(
          academicCalendar: AcademicCalendar(year: academicYearMock),
          schedules: [courseSchedulesUIMock.first],
        );

        await pumpWidget(tester, calendar: initialCalendar);

        expect(
          find.text(courseSchedulesUIMock.first.course.name),
          findsOneWidget,
        );
        expect(
          find.text(courseSchedulesUIMock[1].course.name),
          findsNothing,
        );

        const newCourse = Course(
          id: 'c_updated',
          programId: 'program_1',
          code: 'CS999',
          name: 'Updated Special Course',
          semester: 1,
          credit: 2,
        );
        final updatedSchedule = CourseScheduleUI(
          id: 's_updated',
          academicYearId: academicYearMock.id,
          termId: 'term_1',
          name: 'Updated Class',
          start: DateTime(2025, 9, 8, 9),
          duration: const Duration(minutes: 100),
          cohortId: courseSchedulesUIMock.first.cohortId,
          courseId: newCourse.id,
          programId: 'program_1',
          lecturerId: courseSchedulesUIMock.first.lecturerId,
          roomId: courseSchedulesUIMock.first.roomId,
          cohort: courseSchedulesUIMock.first.cohort,
          course: newCourse,
          lecturer: courseSchedulesUIMock.first.lecturer,
          room: courseSchedulesUIMock.first.room,
        );
        final updatedCalendar = CourseScheduleCalendarUI(
          academicCalendar: AcademicCalendar(year: academicYearMock),
          schedules: [updatedSchedule],
        );

        // Re-pump with updated calendar
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CourseScheduleCalendar(
                calendar: updatedCalendar,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Updated Special Course'),
          findsOneWidget,
        );
        expect(
          find.text(courseSchedulesUIMock.first.course.name),
          findsNothing,
        );
      });
    });
  });
}
