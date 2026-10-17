import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';

import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  final term = academicTermMock;

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function()? onPressed,
    bool selected = false,
  }) {
    return tester.pumpWidgetForTest((context) {
      return AcademicTermListTile(
        selected: selected,
        academicTerm: term,
        onPressed: onPressed,
      );
    });
  }

  group('AcademicTermListTile', () {
    group('Render', () {
      testWidgets('shows academic term name and date subtitle', (
        tester,
      ) async {
        await pumpWidget(tester);

        expect(find.text(term.name), findsOneWidget);
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

        await tester.tap(find.text(term.name));

        expect(pressed, isTrue);
      });
    });
  });
}
