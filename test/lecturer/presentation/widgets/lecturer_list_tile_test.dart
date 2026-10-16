import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';

import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  final lecturer = lecturerUIMock;

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function()? onPressed,
    bool selected = false,
  }) {
    return tester.pumpWidgetForTest((context) {
      return LecturerListTile(
        selected: selected,
        lecturer: lecturer,
        onPressed: onPressed,
      );
    });
  }

  group('LecturerListTile', () {
    group('Render', () {
      testWidgets('shows lecturer name', (tester) async {
        await pumpWidget(tester);

        expect(find.text(lecturer.name), findsOneWidget);
      });

      testWidgets('shows pangkatGolongan and program name', (tester) async {
        await pumpWidget(tester);

        expect(
          find.text('${lecturer.pangkatGolongan} • ${lecturer.program.name}'),
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

        await tester.tap(find.text(lecturer.name));

        expect(pressed, isTrue);
      });
    });
  });
}
