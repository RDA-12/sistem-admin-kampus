import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';

import '../../../common/helper.dart';

void main() {
  final year = AcademicYear(
    id: 'year_1',
    name: '2025/2026',
    startDate: DateTime(2025, 9),
    endDate: DateTime(2026, 8, 31),
  );

  final event = AcademicCalendarEvent(
    id: 'event_1',
    academicYearId: 'year_1',
    name: 'Libur Awal Semester',
    type: AcademicCalendarEventType.holiday,
    start: EventDateTime(
      date: DateTime(2025, 9),
      time: const Time(hour: 0, minute: 0),
    ),
    end: EventDateTime(
      date: DateTime(2025, 9, 3),
      time: const Time(hour: 23, minute: 59),
    ),
  );

  group('AcademicCalendarEventForm', () {
    setUpAll(() async {
      await initializeDateFormatting('id_ID');
    });

    Future<void> pumpWidget(
      WidgetTester tester, {
      AcademicCalendarEvent? initial,
      void Function({
        required String name,
        required AcademicCalendarEventType type,
        required EventDateTime start,
        required EventDateTime end,
        List<String> recurrence,
      })? onSave,
      VoidCallback? onDelete,
      bool isProcessing = false,
      bool isDeleting = false,
    }) {
      return tester.pumpWidgetForTest(
        (context) => AcademicCalendarEventForm(
          academicYear: year,
          initial: initial,
          onSave: onSave ??
              ({
                required name,
                required type,
                required start,
                required end,
                recurrence = const [],
              }) {},
          onDelete: onDelete,
          isProcessing: isProcessing,
          isDeleting: isDeleting,
        ),
      );
    }

    final nameFieldFinder = find.ancestor(
      of: find.text('Nama Kegiatan *'),
      matching: find.byType(TextFormField),
    );
    final startDateFieldFinder = find.ancestor(
      of: find.text('Tanggal Mulai *'),
      matching: find.byType(TextFormField),
    );
    final endDateFieldFinder = find.ancestor(
      of: find.text('Tanggal Selesai *'),
      matching: find.byType(TextFormField),
    );
    final saveButtonFinder = find.widgetWithText(AppButton, 'Simpan');

    group('Render', () {
      testWidgets('shows all fields and submit button', (tester) async {
        await pumpWidget(tester);

        expect(nameFieldFinder, findsOneWidget);
        expect(
          find.byType(DropdownButtonFormField<AcademicCalendarEventType>),
          findsOneWidget,
        );
        expect(startDateFieldFinder, findsOneWidget);
        expect(endDateFieldFinder, findsOneWidget);
        expect(saveButtonFinder, findsOneWidget);
      });

      testWidgets('populates fields with initial event data', (tester) async {
        await pumpWidget(tester, initial: event);

        expect(find.text(event.name), findsOneWidget);
        expect(
          find.text(event.start.date.dateFormat()),
          findsOneWidget,
        );
        expect(
          find.text(event.end.date.dateFormat()),
          findsOneWidget,
        );
      });

      testWidgets('shows loading indicator when isProcessing is true', (
        tester,
      ) async {
        await pumpWidget(tester, isProcessing: true);

        expect(find.byType(LoadingIndicator), findsOneWidget);
      });
    });

    group('Validation', () {
      testWidgets('shows error when submitting empty fields', (tester) async {
        await pumpWidget(tester);

        await tester.tap(saveButtonFinder);
        await tester.pumpAndSettle();

        expect(find.text('Kolom ini wajib diisi'), findsNWidgets(3));
      });

      testWidgets(
        'shows error when end date is before start date',
        (tester) async {
          await pumpWidget(tester);

          await tester.enterText(nameFieldFinder, 'Test Event');
          final startCtrl = tester
              .widget<AppDateFormField>(find.widgetWithText(
                AppDateFormField,
                'Tanggal Mulai *',
              ))
              .controller;
          final endCtrl = tester
              .widget<AppDateFormField>(find.widgetWithText(
                AppDateFormField,
                'Tanggal Selesai *',
              ))
              .controller;

          startCtrl?.value = DateTime(2025, 9, 10);
          endCtrl?.value = DateTime(2025, 9, 5);
          await tester.pumpAndSettle();

          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          expect(
            find.text('Tanggal selesai harus setelah tanggal mulai'),
            findsOneWidget,
          );
        },
      );
    });

    group('Interactions', () {
      testWidgets('calls onSave with valid data when submitted', (
        tester,
      ) async {
        String? savedName;
        AcademicCalendarEventType? savedType;
        EventDateTime? savedStart;
        EventDateTime? savedEnd;

        await pumpWidget(
          tester,
          onSave: ({
            required name,
            required type,
            required start,
            required end,
            recurrence = const [],
          }) {
            savedName = name;
            savedType = type;
            savedStart = start;
            savedEnd = end;
          },
        );

        await tester.enterText(nameFieldFinder, 'Masa KRS');
        final startCtrl = tester
            .widget<AppDateFormField>(find.widgetWithText(
              AppDateFormField,
              'Tanggal Mulai *',
            ))
            .controller;
        final endCtrl = tester
            .widget<AppDateFormField>(find.widgetWithText(
              AppDateFormField,
              'Tanggal Selesai *',
            ))
            .controller;

        startCtrl?.value = DateTime(2025, 9, 2);
        endCtrl?.value = DateTime(2025, 9, 8);
        await tester.pumpAndSettle();

        await tester.tap(saveButtonFinder);
        await tester.pumpAndSettle();

        expect(savedName, 'Masa KRS');
        expect(savedType, AcademicCalendarEventType.holiday);
        expect(savedStart?.date, DateTime(2025, 9, 2));
        expect(savedEnd?.date, DateTime(2025, 9, 8));
      });
    });
  });
}
