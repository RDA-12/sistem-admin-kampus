import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';

import '../helper.dart';

void main() {
  final showButtonFinder = find.byType(FilledButton);

  Future<void> openDialog(WidgetTester tester) async {
    await tester.tap(showButtonFinder);
    await tester.pumpAndSettle();
  }

  final closeButtonFinder = find.ancestor(
    of: find.text('OK'),
    matching: find.byType(AppButton),
  );

  group('showSuccessDialog', () {
    Future<void> pumpWidget(
      WidgetTester tester, {
      String title = 'title',
      String message = 'message',
    }) {
      return tester.pumpWidgetForTest((context) {
        return FilledButton(
          onPressed: () {
            unawaited(
              context.showSuccessDialog(title: title, message: message),
            );
          },
          child: const Text('show'),
        );
      });
    }

    testWidgets('shows correct icon', (tester) async {
      await pumpWidget(tester);

      await openDialog(tester);

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('shows provided title and message', (tester) async {
      await pumpWidget(tester, title: 'test', message: 'message test');

      await openDialog(tester);

      expect(find.text('test'), findsOneWidget);
      expect(find.text('message test'), findsOneWidget);
    });

    testWidgets('shows close button', (tester) async {
      await pumpWidget(tester);

      await openDialog(tester);

      expect(
        closeButtonFinder,
        findsOneWidget,
      );
    });

    group('Interactions', () {
      testWidgets('close dialog when close button pressed', (tester) async {
        await pumpWidget(tester);

        await openDialog(tester);
        expect(find.text('title'), findsOneWidget);

        await tester.tap(closeButtonFinder);
        await tester.pumpAndSettle();
        expect(find.text('title'), findsNothing);
      });
    });
  });

  group('showFailedDialog', () {
    Future<void> pumpWidget(
      WidgetTester tester, {
      String title = 'title',
      String message = 'message',
    }) {
      return tester.pumpWidgetForTest((context) {
        return FilledButton(
          onPressed: () {
            unawaited(
              context.showFailedDialog(title: title, message: message),
            );
          },
          child: const Text('show'),
        );
      });
    }

    testWidgets('shows correct icon', (tester) async {
      await pumpWidget(tester);

      await openDialog(tester);

      expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
    });

    testWidgets('shows provided title and message', (tester) async {
      await pumpWidget(tester, title: 'test', message: 'message test');

      await openDialog(tester);

      expect(find.text('test'), findsOneWidget);
      expect(find.text('message test'), findsOneWidget);
    });

    testWidgets('shows close button', (tester) async {
      await pumpWidget(tester);

      await openDialog(tester);

      expect(
        closeButtonFinder,
        findsOneWidget,
      );
    });

    group('Interactions', () {
      testWidgets('close dialog when close button pressed', (tester) async {
        await pumpWidget(tester);

        await openDialog(tester);
        await tester.pumpAndSettle();
        expect(find.text('title'), findsOneWidget);

        await tester.tap(closeButtonFinder);
        await tester.pumpAndSettle();
        expect(find.text('title'), findsNothing);
      });
    });
  });
}
