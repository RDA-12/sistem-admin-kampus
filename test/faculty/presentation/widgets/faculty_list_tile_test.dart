import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../../common/helper.dart';

void main() {
  const faculty = Faculty(id: 'id', name: 'name');

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function()? onPressed,
    bool selected = false,
  }) {
    return tester.pumpWidgetForTest((context) {
      return FacultyListTile(
        selected: selected,
        faculty: faculty,
        onPressed: onPressed,
      );
    });
  }

  group('FacultyListTile', () {
    group('Render', () {
      testWidgets('shows faculty name', (tester) async {
        await pumpWidget(tester);

        expect(find.text(faculty.name), findsOneWidget);
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

        await tester.tap(find.text(faculty.name));

        expect(pressed, isTrue);
      });
    });
  });
}
