import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';

import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  final year = academicYearMock;
  final term = academicTermMock;

  group('AcademicTermForm', () {
    Future<void> pumpWidget(
      WidgetTester tester, {
      AcademicTerm? initial,
      void Function({
        required String name,
        required DateTime startDate,
        required DateTime endDate,
      })? onSave,
      void Function()? onDelete,
      bool isProcessing = false,
      bool isDeleting = false,
    }) {
      return tester.pumpWidgetForTest(
        (context) => AcademicTermForm(
          academicYear: year,
          initial: initial,
          onSave: onSave ??
              ({
                required name,
                required startDate,
                required endDate,
              }) {},
          onDelete: onDelete,
          isProcessing: isProcessing,
          isDeleting: isDeleting,
        ),
      );
    }

    final nameFieldFinder = find.ancestor(
      of: find.text('Nama Semester *'),
      matching: find.byType(TextFormField),
    );
    final startDateFieldFinder = find.ancestor(
      of: find.text('Tanggal Mulai *'),
      matching: find.byType(AppDateFormField),
    );
    final endDateFieldFinder = find.ancestor(
      of: find.text('Tanggal Selesai *'),
      matching: find.byType(AppDateFormField),
    );
    Future<void> selectDate(
      WidgetTester tester,
      Finder fieldFinder,
      DateTime date,
    ) async {
      await withClock(Clock.fixed(date), () async {
        await tester.tap(fieldFinder);
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      });
    }

    final saveButtonFinder = find.ancestor(
      of: find.text('Simpan'),
      matching: find.byType(AppButton),
    );
    final deleteButtonFinder = find.ancestor(
      of: find.text('Hapus'),
      matching: find.byType(AppButton),
    );

    group('Render', () {
      testWidgets('shows all fields and save button', (tester) async {
        await pumpWidget(tester);

        expect(nameFieldFinder, findsOneWidget);
        expect(startDateFieldFinder, findsOneWidget);
        expect(endDateFieldFinder, findsOneWidget);
        expect(saveButtonFinder, findsOneWidget);
        expect(deleteButtonFinder, findsNothing);
      });

      testWidgets(
        'shows delete button when initial and onDelete are provided',
        (tester) async {
          await pumpWidget(
            tester,
            initial: term,
            onDelete: () {},
          );

          expect(deleteButtonFinder, findsOneWidget);
        },
      );

      testWidgets('shows loading indicator on save button when isProcessing', (
        tester,
      ) async {
        await pumpWidget(tester, isProcessing: true);

        expect(
          find.descendant(
            of: saveButtonFinder,
            matching: find.byType(LoadingIndicator),
          ),
          findsOneWidget,
        );
      });
    });

    group('Interactions', () {
      testWidgets('calls onSave with valid data when submitted', (
        tester,
      ) async {
        String? savedName;
        DateTime? savedStart;
        DateTime? savedEnd;

        await pumpWidget(
          tester,
          onSave: ({
            required name,
            required startDate,
            required endDate,
          }) {
            savedName = name;
            savedStart = startDate;
            savedEnd = endDate;
          },
        );

        await tester.enterText(nameFieldFinder, 'Ganjil');
        await selectDate(tester, startDateFieldFinder, DateTime(2025, 9));
        await selectDate(tester, endDateFieldFinder, DateTime(2026, 1, 31));

        await tester.tap(saveButtonFinder);
        await tester.pumpAndSettle();

        expect(savedName, 'Ganjil');
        expect(savedStart, DateTime(2025, 9));
        expect(savedEnd, DateTime(2026, 1, 31));
      });

      testWidgets(
        'shows validation error when end date is before start date',
        (tester) async {
          var onSaveCalled = false;
          await pumpWidget(
            tester,
            onSave: ({
              required name,
              required startDate,
              required endDate,
            }) {
              onSaveCalled = true;
            },
          );

          await tester.enterText(nameFieldFinder, 'Ganjil');
          await selectDate(tester, startDateFieldFinder, DateTime(2026, 9));
          await selectDate(tester, endDateFieldFinder, DateTime(2025, 8, 31));

          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          expect(
            find.text('Tanggal selesai harus setelah tanggal mulai'),
            findsOneWidget,
          );
          expect(onSaveCalled, isFalse);
        },
      );

      testWidgets('calls onDelete when delete button is confirmed', (
        tester,
      ) async {
        var deleteCalled = false;
        await pumpWidget(
          tester,
          initial: term,
          onDelete: () {
            deleteCalled = true;
          },
        );

        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();

        final confirmFinder = find.ancestor(
          of: find.text('OK'),
          matching: find.byType(AppButton),
        );

        await tester.tap(confirmFinder);
        await tester.pumpAndSettle();

        expect(deleteCalled, isTrue);
      });
    });
  });
}
