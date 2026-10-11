import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';

import '../helper.dart';

void main() {
  const leftPaneKey = ValueKey('left-pane');
  const rightPaneKey = ValueKey('right-pane');

  Future<void> pumpWidget(
    WidgetTester tester, {
    int additionalData = 10,
    Size? phoneSize,
    BoxConstraints? parentConstraints,
    void Function(BoxConstraints)? onLeftConstraints,
    void Function(BoxConstraints)? onRightConstraints,
    void Function(BreakPoint)? onLeftBreakPoint,
    void Function(BreakPoint)? onRightBreakPoint,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return ConstrainedBox(
          constraints: parentConstraints ?? const BoxConstraints(),
          child: TwoPaneLayoutBuilder<int>(
            initialAdditionalData: additionalData,
            leftBuilder: (context, controller, breakPoint, constraints) {
              onLeftConstraints?.call(constraints);
              onLeftBreakPoint?.call(breakPoint);
              return Column(
                key: leftPaneKey,
                children: [
                  FilledButton(
                    onPressed: () {
                      controller.data = 20;
                    },
                    child: const Text('hide-right-panel'),
                  ),
                ],
              );
            },
            rightBuilder: (context, controller, breakPoint, constraints) {
              onRightConstraints?.call(constraints);
              onRightBreakPoint?.call(breakPoint);
              if (controller.data == 20) {
                return const SizedBox();
              }
              return const SizedBox(key: rightPaneKey);
            },
          ),
        );
      },
      phoneSize: phoneSize,
    );
  }

  group('TwoPaneLayoutBuilder', () {
    final hideRightPanelButtonFinder = find.ancestor(
      of: find.text('hide-right-panel'),
      matching: find.byType(FilledButton),
    );

    group('Render', () {
      testWidgets('shows left pane only in compact screen', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(450, 800));

        expect(find.byKey(leftPaneKey), findsOneWidget);
        expect(find.byKey(rightPaneKey), findsNothing);
      });

      testWidgets('shows left pane only in medium screen', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(800, 800));

        expect(find.byKey(leftPaneKey), findsOneWidget);
        expect(find.byKey(rightPaneKey), findsNothing);
      });

      testWidgets('shows left and right pane '
          'in expanded screen', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(1000, 800));

        expect(find.byKey(leftPaneKey), findsOneWidget);
        expect(find.byKey(rightPaneKey), findsOneWidget);
      });

      testWidgets('shows left and right pane '
          'in large screen', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(1300, 800));

        expect(find.byKey(leftPaneKey), findsOneWidget);
        expect(find.byKey(rightPaneKey), findsOneWidget);
      });

      testWidgets('can change layout based on controller', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(1300, 800));

        expect(find.byKey(leftPaneKey), findsOneWidget);
        expect(find.byKey(rightPaneKey), findsOneWidget);

        await tester.tap(hideRightPanelButtonFinder);
        await tester.pumpAndSettle();

        expect(find.byKey(leftPaneKey), findsOneWidget);
        expect(find.byKey(rightPaneKey), findsNothing);
      });

      testWidgets('provide correct breakPoint', (tester) async {
        const expectedBreakPoint = BreakPoint.large;

        late final BreakPoint leftBreakPoint;
        late final BreakPoint rightBreakPoint;

        await pumpWidget(
          tester,
          phoneSize: const Size(1500, 800),
          onLeftBreakPoint: (c) {
            leftBreakPoint = c;
          },
          onRightBreakPoint: (c) {
            rightBreakPoint = c;
          },
        );

        expect(leftBreakPoint, expectedBreakPoint);
        expect(rightBreakPoint, expectedBreakPoint);
      });

      testWidgets('provide correct constraints', (tester) async {
        const parentWidth = 1248;
        const paintablePanes = parentWidth - (2 * AppSpacing.paneSpacing);
        const paneMaxWidth = paintablePanes / 2;
        final parentConstraints = BoxConstraints.tight(
          Size(parentWidth.toDouble(), 800),
        );
        final expectedConstraints = BoxConstraints(
          minWidth: paneMaxWidth,
          maxWidth: paneMaxWidth,
          // ignore: avoid_redundant_argument_values need verbosity
          minHeight: 0,
          maxHeight: parentConstraints.maxHeight,
        );

        late final BoxConstraints leftConstraints;
        late final BoxConstraints rightConstraints;

        await pumpWidget(
          tester,
          parentConstraints: parentConstraints,
          phoneSize: Size(parentWidth.toDouble(), 800),
          onLeftConstraints: (c) {
            leftConstraints = c;
          },
          onRightConstraints: (c) {
            rightConstraints = c;
          },
        );

        expect(leftConstraints, expectedConstraints);
        expect(rightConstraints, expectedConstraints);
      });
    });
  });
}
