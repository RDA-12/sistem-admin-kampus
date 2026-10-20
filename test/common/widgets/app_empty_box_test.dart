import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';

import '../helper.dart';

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    String? message,
    BoxConstraints? constraints,
  }) {
    return tester.pumpWidgetForTest((context) {
      return Center(
        child: AppEmptyBox(
          message: message ?? 'Belum ada data',
          constraints:
              constraints ??
              const BoxConstraints(
                minWidth: 120,
                minHeight: 120,
              ),
        ),
      );
    });
  }

  group('AppEmptyBox', () {
    group('Render', () {
      testWidgets('shows default message when not specified', (tester) async {
        await tester.pumpWidgetForTest((context) {
          return const Center(
            child: AppEmptyBox(),
          );
        });

        expect(find.text('Belum ada data'), findsOneWidget);
      });

      testWidgets('shows custom message', (tester) async {
        await pumpWidget(tester, message: 'Tidak ada item');

        expect(find.text('Tidak ada item'), findsOneWidget);
      });

      testWidgets('enforces default min size constraints', (tester) async {
        await pumpWidget(tester, message: 'A');

        final size = tester.getSize(find.byType(AppEmptyBox));
        expect(size.width, greaterThanOrEqualTo(120));
        expect(size.height, greaterThanOrEqualTo(120));
      });

      testWidgets('enforces custom constraints', (tester) async {
        await pumpWidget(
          tester,
          message: 'A',
          constraints: const BoxConstraints(minWidth: 200, minHeight: 160),
        );

        final size = tester.getSize(find.byType(AppEmptyBox));
        expect(size.width, greaterThanOrEqualTo(200));
        expect(size.height, greaterThanOrEqualTo(160));
      });
    });
  });
}
