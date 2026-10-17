import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';

import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  final year = academicYearMock;

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function()? onPressed,
    bool selected = false,
  }) {
    return tester.pumpWidgetForTest((context) {
      return AcademicYearListTile(
        selected: selected,
        academicYear: year,
        onPressed: onPressed,
      );
    });
  }

  group('AcademicYearListTile', () {
    group('Render', () {
      testWidgets('shows academic year name and date subtitle', (
        tester,
      ) async {
        await pumpWidget(tester);

        expect(find.text(year.name), findsOneWidget);
        expect(find.byType(AppListTile), findsOneWidget);
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

        await tester.tap(find.text(year.name));

        expect(pressed, isTrue);
      });
    });
  });
}
