import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';

import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function()? onPressed,
    bool selected = false,
  }) {
    return tester.pumpWidgetForTest((context) {
      return CohortListTile(
        selected: selected,
        cohort: cohortMock,
        onPressed: onPressed,
      );
    });
  }

  group('CohortListTile', () {
    group('Render', () {
      testWidgets('shows cohort name and entry year', (tester) async {
        await pumpWidget(tester);

        expect(find.text(cohortMock.name), findsOneWidget);
        expect(
          find.text('Tahun Masuk: ${cohortMock.entryYear}'),
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

        await tester.tap(find.text(cohortMock.name));

        expect(pressed, isTrue);
      });
    });
  });
}
