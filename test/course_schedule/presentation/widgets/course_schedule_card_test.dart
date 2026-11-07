import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';

import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  final schedule = courseScheduleUIMock;

  Future<void> pumpWidget(
    WidgetTester tester, {
    CourseScheduleUI? scheduleToUse,
    void Function()? onPressed,
  }) {
    return tester.pumpWidgetForTest((context) {
      return CourseScheduleCard(
        schedule: scheduleToUse ?? schedule,
        onPressed: onPressed,
      );
    });
  }

  group('CourseScheduleCard', () {
    group('Render', () {
      testWidgets('shows course name', (tester) async {
        await pumpWidget(tester);

        expect(find.text(schedule.course.name), findsOneWidget);
      });

      testWidgets('shows formatted time range', (tester) async {
        await pumpWidget(tester);

        final startTime = schedule.start.timeFormat();
        final endTime = schedule.start.add(schedule.duration).timeFormat();
        expect(find.text('$startTime - $endTime'), findsOneWidget);
      });

      testWidgets('shows room and cohort name', (tester) async {
        await pumpWidget(tester);

        expect(
          find.text('${schedule.room.name} • ${schedule.cohort.name}'),
          findsOneWidget,
        );
      });

      testWidgets('shows lecturer name when lecturer name is not empty', (
        tester,
      ) async {
        await pumpWidget(tester);

        expect(find.text(schedule.lecturer.name), findsOneWidget);
      });

      testWidgets(
        'does not show lecturer name when lecturer name is empty',
        (tester) async {
          const emptyLecturer = Lecturer(
            id: 'l_empty',
            programId: 'p_1',
            name: '',
            pangkatGolongan: '',
          );
          final scheduleWithoutLecturer = CourseScheduleUI(
            id: schedule.id,
            academicYearId: schedule.academicYearId,
            termId: schedule.termId,
            name: schedule.name,
            start: schedule.start,
            duration: schedule.duration,
            cohortId: schedule.cohortId,
            courseId: schedule.courseId,
            programId: schedule.programId,
            lecturerId: emptyLecturer.id,
            roomId: schedule.roomId,
            cohort: schedule.cohort,
            course: schedule.course,
            lecturer: emptyLecturer,
            room: schedule.room,
          );

          await pumpWidget(tester, scheduleToUse: scheduleWithoutLecturer);

          expect(find.text(schedule.lecturer.name), findsNothing);
        },
      );
    });

    group('Interactions', () {
      testWidgets('calls onPressed when tapped', (tester) async {
        var pressed = false;
        await pumpWidget(
          tester,
          onPressed: () {
            pressed = true;
          },
        );

        await tester.tap(find.text(schedule.course.name));

        expect(pressed, isTrue);
      });
    });
  });
}
