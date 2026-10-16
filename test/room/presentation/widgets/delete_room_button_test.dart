import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/room/room.dart';

import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function()? onConfirmed,
  }) {
    return tester.pumpWidgetForTest((context) {
      return DeleteRoomButton(
        room: roomMock,
        onConfirmed: onConfirmed,
      );
    });
  }

  group('DeleteRoomButton', () {
    Future<void> deleteButtonPressed(WidgetTester tester) async {
      final finder = find.byType(AppButton);

      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    group('Render', () {
      testWidgets('shows delete label', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Hapus'), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets(
        'shows confirmation dialog with correct title and message '
        'when the button is pressed',
        (tester) async {
          await pumpWidget(tester);

          await deleteButtonPressed(tester);

          expect(find.text('Hapus ${roomMock.name}'), findsOneWidget);
          expect(
            find.text(
              'Data yang berhubungan dengan ${roomMock.name} '
              'akan tetap ada. Tapi, ruangan tersebut '
              'tidak lagi bisa digunakan untuk proses lain',
            ),
            findsOneWidget,
          );
        },
      );
    });

    group('Side Effects', () {
      testWidgets(
        'calls onConfirmed when confirm button pressed in confirmation dialog',
        (tester) async {
          var confirmed = false;
          await pumpWidget(
            tester,
            onConfirmed: () {
              confirmed = true;
            },
          );

          await deleteButtonPressed(tester);

          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();

          expect(confirmed, isTrue);
        },
      );

      testWidgets(
        'not calls onConfirmed when cancel button pressed '
        'in confirmation dialog',
        (tester) async {
          var confirmed = false;
          await pumpWidget(
            tester,
            onConfirmed: () {
              confirmed = true;
            },
          );

          await deleteButtonPressed(tester);

          await tester.tap(find.text('Batal'));
          await tester.pumpAndSettle();

          expect(confirmed, isFalse);
        },
      );
    });
  });
}
