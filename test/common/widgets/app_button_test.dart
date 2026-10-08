import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/widgets/app_button.dart';

import '../helper.dart';

void main() {
  group('AppButton', () {
    Future<void> pumpWidget(
      WidgetTester tester, {
      String label = 'Label',
      VoidCallback? onPressed,
    }) {
      return tester.pumpWidgetForTest(
        (context) => AppButton(
          label: label,
          onPressed: onPressed,
        ),
      );
    }

    group('Render', () {
      testWidgets('shows correct label', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Label'), findsOneWidget);
      });

      testWidgets('shows FilledButton', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(FilledButton), findsOneWidget);
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

        await tester.tap(find.byType(FilledButton));

        expect(pressed, isTrue);
      });
    });
  });
}
