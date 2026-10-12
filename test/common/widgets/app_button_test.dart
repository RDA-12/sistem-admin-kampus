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
      Widget? leadingIcon,
      AppButtonType type = AppButtonType.filled,
    }) {
      return tester.pumpWidgetForTest(
        (context) => AppButton(
          label: label,
          onPressed: onPressed,
          leadingIcon: leadingIcon,
          type: type,
        ),
      );
    }

    group('Render', () {
      testWidgets('shows correct label', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Label'), findsOneWidget);
      });

      testWidgets('shows FilledButton when type is filled', (tester) async {
        // ignore: avoid_redundant_argument_values need verbosity
        await pumpWidget(tester, type: AppButtonType.filled);

        expect(find.byType(FilledButton), findsOneWidget);
      });

      testWidgets('shows TextButton when type is text', (tester) async {
        await pumpWidget(tester, type: AppButtonType.text);

        expect(find.byType(TextButton), findsOneWidget);
      });

      for (final type in AppButtonType.values) {
        testWidgets('shows leadingIcon in $type '
            'when provided', (tester) async {
          const leadingIcon = Icon(Icons.abc);

          await pumpWidget(tester, leadingIcon: leadingIcon, type: type);

          expect(find.byWidget(leadingIcon), findsOneWidget);
        });
      }
    });

    group('Interactions', () {
      for (final type in AppButtonType.values) {
        testWidgets('calls onPressed in $type '
            'when pressed', (tester) async {
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
      }
    });
  });
}
