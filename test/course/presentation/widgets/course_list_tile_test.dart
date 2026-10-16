import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/course.dart';

import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  final course = courseUIMock;

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function()? onPressed,
    bool selected = false,
  }) {
    return tester.pumpWidgetForTest((context) {
      return CourseListTile(
        selected: selected,
        course: course,
        onPressed: onPressed,
      );
    });
  }

  group('CourseListTile', () {
    group('Render', () {
      testWidgets('shows course name', (tester) async {
        await pumpWidget(tester);

        expect(find.text(course.name), findsOneWidget);
      });

      testWidgets('shows code, credit, semester, and program name', (
        tester,
      ) async {
        await pumpWidget(tester);

        expect(
          find.text(
            '${course.code} • ${course.credit} SKS • '
            'Semester ${course.semester} • ${course.program.name}',
          ),
          findsOneWidget,
        );
      });

      testWidgets('shows selected AppListTile when selected is true', (
        tester,
      ) async {
        await pumpWidget(tester, selected: true);

        final finder = find.byType(AppListTile);
        expect(finder, findsOneWidget);
        final widget = tester.widget<AppListTile>(finder);
        expect(widget.selected, isTrue);
      });
    });

    group('Interactions', () {
      testWidgets('calls onPressed when pressed', (tester) async {
        var pressed = false;
        await pumpWidget(
          tester,
          onPressed: () {
            pressed = true;
          },
        );

        await tester.tap(find.text(course.name));

        expect(pressed, isTrue);
      });
    });
  });
}
