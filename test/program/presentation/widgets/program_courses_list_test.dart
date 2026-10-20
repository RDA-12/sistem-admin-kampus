import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/program/presentation/widgets/program_courses_list.dart';

import '../../../common/helper.dart';
import '../../../course/domain/mocks.dart';

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    required List<Course> courses,
    void Function(Course)? onPressed,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return CustomScrollView(
          slivers: [
            ProgramCoursesList(
              courses: courses,
              onPressed: onPressed,
            ),
          ],
        );
      },
    );
  }

  group('ProgramCoursesList', () {
    group('Render', () {
      testWidgets(
        'shows list of courses with correct title and subtitle',
        (tester) async {
          await pumpWidget(tester, courses: coursesMock);

          for (final course in coursesMock) {
            final finder = find.ancestor(
              of: find.text(course.name),
              matching: find.byType(AppListTile),
            );
            await tester.ensureVisible(finder);
            expect(finder, findsOneWidget);
            expect(
              find.descendant(
                of: finder,
                matching: find.text(
                  '${course.code} • ${course.credit} SKS • '
                  'Semester ${course.semester}',
                ),
              ),
              findsOneWidget,
            );
          }
        },
      );

      testWidgets('shows AppEmptyBox when course list is empty', (
        tester,
      ) async {
        await pumpWidget(tester, courses: const []);

        expect(find.byType(AppListTile), findsNothing);
        final finder = find.byType(AppEmptyBox);
        expect(finder, findsOneWidget);
        final widget = tester.widget<AppEmptyBox>(finder);
        expect(widget.message, 'Belum ada data mata kuliah');
      });
    });

    group('Interactions', () {
      testWidgets(
        'calls onPressed with correct course when tile is pressed',
        (tester) async {
          Course? pressedCourse;
          await pumpWidget(
            tester,
            courses: coursesMock,
            onPressed: (c) => pressedCourse = c,
          );

          final target = coursesMock.first;
          final finder = find.ancestor(
            of: find.text(target.name),
            matching: find.byType(AppListTile),
          );
          await tester.ensureVisible(finder);
          await tester.tap(finder);

          expect(pressedCourse, target);
        },
      );
    });
  });
}
