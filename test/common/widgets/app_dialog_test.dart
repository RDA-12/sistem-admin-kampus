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

  group('showConfirmationDialog', () {
    Future<void> pumpWidget(
      WidgetTester tester, {
      String title = 'title',
      String message = 'message',
      // ignore: avoid_positional_boolean_parameters no need
      void Function(bool)? onResult,
    }) {
      return tester.pumpWidgetForTest((context) {
        return FilledButton(
          onPressed: () async {
            final result = await context.showConfirmationDialog(
              title: title,
              message: message,
            );
            onResult?.call(result);
          },
          child: const Text('show'),
        );
      });
    }

    final confirmButtonFinder = find.ancestor(
      of: find.text('OK'),
      matching: find.byType(AppButton),
    );
    final cancelButtonFinder = find.ancestor(
      of: find.text('Batal'),
      matching: find.byType(AppButton),
    );

    group('Render', () {
      testWidgets('shows provided title and message', (tester) async {
        await pumpWidget(tester, title: 'test', message: 'message test');

        await openDialog(tester);

        expect(find.text('test'), findsOneWidget);
        expect(find.text('message test'), findsOneWidget);
      });

      testWidgets('shows confirmed button', (tester) async {
        await pumpWidget(tester);

        await openDialog(tester);

        expect(confirmButtonFinder, findsOneWidget);
      });

      testWidgets('shows cancel button', (tester) async {
        await pumpWidget(tester);

        await openDialog(tester);

        expect(cancelButtonFinder, findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets(
        'return true when confirmed button pressed',
        (tester) async {
          bool? result;
          await pumpWidget(
            tester,
            onResult: (v) {
              result = v;
            },
          );

          await openDialog(tester);

          await tester.tap(confirmButtonFinder);
          await tester.pumpAndSettle();

          expect(result, isTrue);
        },
      );

      testWidgets(
        'return false when cancel button pressed',
        (tester) async {
          bool? result;
          await pumpWidget(
            tester,
            onResult: (v) {
              result = v;
            },
          );

          await openDialog(tester);

          await tester.tap(cancelButtonFinder);
          await tester.pumpAndSettle();

          expect(result, isFalse);
        },
      );
    });
  });

  group('showAppDialog', () {
    Future<void> pumpWidget<T>(
      WidgetTester tester, {
      String title = 'title',
      Widget Function(BuildContext)? contentBuilder,
      void Function(T?)? onResult,
      List<Widget> Function(BuildContext)? actionsBuilder,
    }) {
      return tester.pumpWidgetForTest((context) {
        return FilledButton(
          onPressed: () async {
            final result = await context.showAppDialog<T?>(
              title: title,
              contentBuilder: contentBuilder ?? (_) => const Text('data'),
              actionsBuilder: actionsBuilder,
            );
            onResult?.call(result);
          },
          child: const Text('show'),
        );
      });
    }

    group('Render', () {
      testWidgets('shows title', (tester) async {
        await pumpWidget<void>(tester, title: 'Title');

        await openDialog(tester);

        expect(find.text('Title'), findsOneWidget);
      });

      testWidgets('shows content', (tester) async {
        await pumpWidget<void>(
          tester,
          contentBuilder: (_) => const Text('content'),
        );

        await openDialog(tester);

        expect(find.text('content'), findsOneWidget);
      });

      testWidgets('shows actions', (tester) async {
        await pumpWidget<void>(
          tester,
          actionsBuilder: (context) {
            return [
              FilledButton(
                child: const Text('action 1'),
                onPressed: () {},
              ),
              FilledButton(
                child: const Text('action 2'),
                onPressed: () {},
              ),
            ];
          },
        );

        await openDialog(tester);

        expect(find.text('action 1'), findsOneWidget);
        expect(find.text('action 2'), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets('can close dialog from actionsBuilder', (tester) async {
        await pumpWidget<void>(
          tester,
          title: 'Title',
          actionsBuilder: (context) {
            return [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('close'),
              ),
            ];
          },
        );

        await openDialog(tester);
        expect(find.text('Title'), findsOneWidget);

        await tester.tap(find.text('close'));
        await tester.pumpAndSettle();

        expect(find.text('Title'), findsNothing);
      });

      testWidgets('can close dialog from contentBuilder', (tester) async {
        await pumpWidget<void>(
          tester,
          title: 'Title',
          contentBuilder: (context) {
            return FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('close'),
            );
          },
        );

        await openDialog(tester);
        expect(find.text('Title'), findsOneWidget);

        await tester.tap(find.text('close'));
        await tester.pumpAndSettle();

        expect(find.text('Title'), findsNothing);
      });

      testWidgets('returns correct data', (tester) async {
        String? res;
        await pumpWidget<String?>(
          tester,
          title: 'Title',
          onResult: (v) {
            res = v;
          },
          actionsBuilder: (context) {
            return [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context, 'result');
                },
                child: const Text('close'),
              ),
            ];
          },
        );

        await openDialog(tester);
        expect(find.text('Title'), findsOneWidget);

        await tester.tap(find.text('close'));
        await tester.pumpAndSettle();

        expect(res, 'result');
      });
    });
  });
}
