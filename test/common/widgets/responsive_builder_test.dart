import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';

import '../helper.dart';

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    Size phoneSize = const Size(600, 800),
    BoxConstraints? parentConstraints,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        final child = ResponsiveBuilder(
          builder: (context, breakpoint, constraints) {
            return Column(
              children: [
                Text('BreakPoint: ${breakpoint.name}'),
                Text('maxWidth: ${constraints.maxWidth}'),
                Text('minWidth: ${constraints.minWidth}'),
                Text('maxHeight: ${constraints.maxHeight}'),
                Text('minHeight: ${constraints.minHeight}'),
              ],
            );
          },
        );
        if (parentConstraints != null) {
          return ConstrainedBox(
            constraints: parentConstraints,
            child: child,
          );
        }
        return child;
      },
      phoneSize: phoneSize,
    );
  }

  group('BreakPoint', () {
    testWidgets('has correct order', (tester) async {
      final breakpoints = List<BreakPoint>.from(BreakPoint.values)
        ..shuffle()
        ..sort((a, b) => a.compareTo(b));

      expect(breakpoints, [
        BreakPoint.compact,
        BreakPoint.medium,
        BreakPoint.expanded,
        BreakPoint.large,
      ]);
    });

    testWidgets('has correct > operator', (tester) async {
      expect(BreakPoint.medium > BreakPoint.compact, isTrue);
      expect(BreakPoint.medium > BreakPoint.expanded, isFalse);
    });

    testWidgets('has correct > operator', (tester) async {
      expect(BreakPoint.medium < BreakPoint.compact, isFalse);
      expect(BreakPoint.medium < BreakPoint.expanded, isTrue);
    });

    testWidgets('has correct inside method', (tester) async {
      expect(BreakPoint.medium.inside([BreakPoint.compact]), isFalse);
      expect(
        BreakPoint.medium.inside([BreakPoint.medium, BreakPoint.compact]),
        isTrue,
      );
    });
  });

  group('ResponsiveBuilder', () {
    group('Render', () {
      testWidgets(
        'provides BreakPoint.compact when width < 600',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(400, 800));

          expect(
            find.text('BreakPoint: ${BreakPoint.compact.name}'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'provides BreakPoint.medium when 600 <= width < 840',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(640, 800));

          expect(
            find.text('BreakPoint: ${BreakPoint.medium.name}'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'provides BreakPoint.expanded when 840 <= width < 1200',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(840, 800));

          expect(
            find.text('BreakPoint: ${BreakPoint.expanded.name}'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'provides BreakPoint.large when width >= 1200',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1200, 800));

          expect(
            find.text('BreakPoint: ${BreakPoint.large.name}'),
            findsOneWidget,
          );
        },
      );

      testWidgets('provides correct constraints', (tester) async {
        const constraints = BoxConstraints(
          maxWidth: 320,
          minWidth: 120,
          maxHeight: 240,
          minHeight: 120,
        );
        await pumpWidget(
          tester,
          parentConstraints: constraints,
        );

        expect(find.text('maxWidth: ${constraints.maxWidth}'), findsOneWidget);
        expect(find.text('minWidth: ${constraints.minWidth}'), findsOneWidget);
        expect(
          find.text('maxHeight: ${constraints.maxHeight}'),
          findsOneWidget,
        );
        expect(
          find.text('maxHeight: ${constraints.maxHeight}'),
          findsOneWidget,
        );
      });
    });
  });
}
