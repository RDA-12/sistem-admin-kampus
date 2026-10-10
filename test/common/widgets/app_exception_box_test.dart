import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../helper.dart';

void main() {
  final exception = AppException.test();

  Future<void> pumpWidget(
    WidgetTester tester, {
    String title = 'title',
    void Function()? onRetryPressed,
  }) {
    return tester.pumpWidgetForTest((context) {
      return AppExceptionBox(
        title: title,
        exception: exception,
        onRetryPressed: onRetryPressed,
      );
    });
  }

  group('AppExceptionBox', () {
    final retryButtonFinder = find.ancestor(
      of: find.text('Coba lagi'),
      matching: find.byType(AppButton),
    );

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester, title: 'test');

        expect(find.text('test'), findsOneWidget);
      });

      testWidgets('shows exception message', (tester) async {
        await pumpWidget(tester);

        expect(find.text(exception.code.message), findsOneWidget);
      });

      testWidgets(
        'hides retry button when onRetryPressed not provided',
        (tester) async {
          await pumpWidget(tester);

          expect(retryButtonFinder, findsNothing);
        },
      );

      testWidgets(
        'shows retry button when onRetryPressed provided',
        (tester) async {
          await pumpWidget(tester, onRetryPressed: () {});

          expect(retryButtonFinder, findsOneWidget);
        },
      );
    });

    group('Interactions', () {
      testWidgets('calls onRetryPressed when retry button pressed', (
        tester,
      ) async {
        var pressed = false;
        await pumpWidget(
          tester,
          onRetryPressed: () {
            pressed = true;
          },
        );

        await tester.tap(retryButtonFinder);

        expect(pressed, isTrue);
      });
    });
  });
}
