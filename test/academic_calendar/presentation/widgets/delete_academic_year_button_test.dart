import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';

import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function()? onConfirmed,
    bool isDeleting = false,
    bool disable = false,
  }) {
    return tester.pumpWidgetForTest((context) {
      return DeleteAcademicYearButton(
        academicYear: academicYearMock,
        onConfirmed: onConfirmed,
        isDeleting: isDeleting,
        disable: disable,
      );
    });
  }

  group('DeleteAcademicYearButton', () {
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

      testWidgets('shows loading indicator when isDeleting is true', (
        tester,
      ) async {
        await pumpWidget(tester, isDeleting: true);

        expect(find.byType(LoadingIndicator), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets(
        'shows confirmation dialog with correct title and message '
        'when the button is pressed',
        (tester) async {
          await pumpWidget(tester);

          await deleteButtonPressed(tester);

          expect(
            find.text('Hapus ${academicYearMock.name}'),
            findsOneWidget,
          );
          expect(
            find.text(
              'Data yang berhubungan dengan ${academicYearMock.name} '
              'akan tetap ada. Tapi, tahun akademik tersebut '
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

          final confirmButtonFinder = find.ancestor(
            of: find.text('OK'),
            matching: find.byType(AppButton),
          );

          await tester.tap(confirmButtonFinder);
          await tester.pumpAndSettle();

          expect(confirmed, isTrue);
        },
      );

      testWidgets(
        'does not call onConfirmed when cancel button pressed',
        (tester) async {
          var confirmed = false;
          await pumpWidget(
            tester,
            onConfirmed: () {
              confirmed = true;
            },
          );

          await deleteButtonPressed(tester);

          final cancelButtonFinder = find.ancestor(
            of: find.text('Batal'),
            matching: find.byType(AppButton),
          );

          await tester.tap(cancelButtonFinder);
          await tester.pumpAndSettle();

          expect(confirmed, isFalse);
        },
      );
    });
  });
}
