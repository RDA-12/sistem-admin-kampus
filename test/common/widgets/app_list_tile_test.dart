import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';

import '../helper.dart';

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    Widget? title,
    Widget? subtitle,
    Widget? trailing,
    VoidCallback? onPressed,
    bool selected = false,
  }) {
    return tester.pumpWidgetForTest((context) {
      return AppListTile(
        title: title ?? const Text('title'),
        subtitle: subtitle,
        trailing: trailing,
        onPressed: onPressed,
        selected: selected,
      );
    });
  }

  group('AppListTile', () {
    group('Render', () {
      testWidgets('shows title', (tester) async {
        await pumpWidget(tester, title: const Text('title'));

        expect(find.text('title'), findsOneWidget);
      });

      testWidgets('shows subtitle when provided', (tester) async {
        await pumpWidget(tester, subtitle: const Text('subtitle'));

        expect(find.text('subtitle'), findsOneWidget);
      });

      testWidgets('shows trailing when provided', (tester) async {
        await pumpWidget(tester, trailing: const Text('trailing'));

        expect(find.text('trailing'), findsOneWidget);
      });

      testWidgets('set correct selected', (tester) async {
        await pumpWidget(tester, selected: true);

        final widget = tester.widget<ListTile>(find.byType(ListTile));
        expect(widget.selected, isTrue);
      });
    });

    group('Interactions', () {
      testWidgets('calls onPressed when pressed', (tester) async {
        var pressed = false;
        await pumpWidget(
          tester,
          title: const Text('title'),
          onPressed: () {
            pressed = true;
          },
        );

        await tester.tap(find.text('title'));

        expect(pressed, isTrue);
      });
    });
  });
}
