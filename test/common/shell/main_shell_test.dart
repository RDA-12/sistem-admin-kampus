import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';

import '../helper.dart';

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    int currentIndex = 0,
    void Function(int)? onDestinationChanged,
    Size? phoneSize,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return MainShell(
          currentIndex: currentIndex,
          onDestinationChanged: onDestinationChanged ?? (_) {},
          child: const SizedBox(
            key: ValueKey('child'),
          ),
        );
      },
      phoneSize: phoneSize,
    );
  }

  group('MainShell', () {
    final navRailFinder = find.byType(NavigationRail);

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Sistem Administrasi'), findsOneWidget);
      });

      testWidgets('hides title on compact screen', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(450, 800));

        expect(find.text('Sistem Administrasi'), findsNothing);
      });

      testWidgets('shows child', (tester) async {
        await pumpWidget(tester);

        expect(find.byKey(const ValueKey('child')), findsOneWidget);
      });

      testWidgets('has NavigationRail in drawer '
          'in compact screen', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(560, 800));

        final drawerButtonFinder = find.byType(DrawerButton);
        expect(drawerButtonFinder, findsOneWidget);

        await tester.tap(drawerButtonFinder);
        await tester.pumpAndSettle();

        expect(navRailFinder, findsOneWidget);
      });

      testWidgets(
        'shows collapsed NavigationRail in medium screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(601, 800));

          expect(navRailFinder, findsOneWidget);
          final widget = tester.widget<NavigationRail>(navRailFinder);
          expect(widget.extended, isFalse);
        },
      );

      testWidgets(
        'shows collapsed NavigationRail in expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(850, 800));

          expect(navRailFinder, findsOneWidget);
          final widget = tester.widget<NavigationRail>(navRailFinder);
          expect(widget.extended, isFalse);
        },
      );

      testWidgets(
        'shows expanded NavigationRail in large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1201, 800));

          expect(navRailFinder, findsOneWidget);
          final widget = tester.widget<NavigationRail>(navRailFinder);
          expect(widget.extended, isTrue);
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'calls onDestinationChanged when destination is pressed',
        (tester) async {
          int? indexPressed;
          await pumpWidget(
            tester,
            onDestinationChanged: (index) {
              indexPressed = index;
            },
          );

          final navRail = tester.widget<NavigationRail>(navRailFinder);
          final firstDestination = navRail.destinations.first;
          final firstDestinationFinder = find.byWidget(firstDestination.label);
          await tester.tap(firstDestinationFinder);

          expect(indexPressed, 0);
        },
      );
    });
  });
}
