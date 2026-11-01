import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';

void main() {
  final year = AcademicYear(
    id: 'id',
    name: '2025/2026',
    startDate: DateTime(2025, 9),
    endDate: DateTime(2026, 8, 31),
  );
  final term = AcademicTerm(
    id: 'term_1',
    academicYearId: 'id',
    name: 'Ganjil',
    startDate: DateTime(2025, 9),
    endDate: DateTime(2026, 1, 31),
  );
  final event = AcademicCalendarEvent(
    id: 'event_1',
    academicYearId: 'id',
    name: 'Libur Idul Fitri',
    type: AcademicCalendarEventType.holiday,
    start: EventDateTime(
      date: DateTime(2026, 3, 20),
      time: const Time(hour: 0, minute: 0),
    ),
    end: EventDateTime(
      date: DateTime(2026, 3, 25),
      time: const Time(hour: 23, minute: 59),
    ),
  );

  late AcademicCalendarMutationBloc academicCalendarMutationBlocMock;

  group('AcademicCalendarForm', () {
    setUpAll(() async {
      initializeMockDependencies();
      await initializeDateFormatting('id_ID');
    });

    setUp(() {
      academicCalendarMutationBlocMock = getIt<AcademicCalendarMutationBloc>();
      whenListen(
        academicCalendarMutationBlocMock,
        Stream.value(const AcademicCalendarMutationState()),
        initialState: const AcademicCalendarMutationState(),
      );
    });

    Future<void> pumpWidget(
      WidgetTester tester, {
      void Function(AcademicCalendar)? onCalendarCreated,
    }) {
      return tester.pumpWidgetForTest(
        (context) => AcademicCalendarForm(
          onCalendarCreated: onCalendarCreated,
        ),
        phoneSize: const Size(1024, 1200),
        providerBuilder: (context, child) {
          return BlocProvider.value(
            value: academicCalendarMutationBlocMock,
            child: child,
          );
        },
      );
    }

    tearDown(() {
      reset(academicCalendarMutationBlocMock);
    });

    group('Render', () {
      testWidgets('shows Stepper and AcademicYearForm initially', (
        tester,
      ) async {
        await pumpWidget(tester);

        expect(find.text('Tahun Akademik'), findsOneWidget);
        expect(find.text('Semester Akademik'), findsOneWidget);
        expect(find.text('Kegiatan Akademik'), findsOneWidget);
        expect(find.byType(AcademicYearForm), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets(
        'dispatches AcademicCalendarYearCreateRequested when year form saves',
        (tester) async {
          await pumpWidget(tester);

          final yearForm = tester.widget<AcademicYearForm>(
            find.byType(AcademicYearForm),
          );
          yearForm.onSave(
            name: '2025/2026',
            startDate: DateTime(2025, 9),
            endDate: DateTime(2026, 8, 31),
          );

          verify(
            () => academicCalendarMutationBlocMock.add(
              AcademicCalendarYearCreateRequested(
                name: '2025/2026',
                startDate: DateTime(2025, 9),
                endDate: DateTime(2026, 8, 31),
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'advances to Step 1 and shows AcademicTermForm when year created',
        (tester) async {
          final controller = StreamController<AcademicCalendarMutationState>();
          addTearDown(controller.close);

          whenListen(
            academicCalendarMutationBlocMock,
            controller.stream,
            initialState: const AcademicCalendarMutationState(),
          );

          await pumpWidget(tester);

          controller.add(
            AcademicCalendarMutationState(
              notice: AcademicYearCreatedNotice(year),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Tahun akademik berhasil disimpan'), findsOneWidget);
          expect(find.byType(AcademicTermForm), findsOneWidget);
        },
      );

      testWidgets(
        'dispatches AcademicCalendarTermCreateRequested when term form saves',
        (tester) async {
          final controller = StreamController<AcademicCalendarMutationState>();
          addTearDown(controller.close);

          whenListen(
            academicCalendarMutationBlocMock,
            controller.stream,
            initialState: const AcademicCalendarMutationState(),
          );

          await pumpWidget(tester);

          controller.add(
            AcademicCalendarMutationState(
              notice: AcademicYearCreatedNotice(year),
            ),
          );
          await tester.pumpAndSettle();

          final okFinder = find.ancestor(
            of: find.text('OK'),
            matching: find.byType(AppButton),
          );
          await tester.tap(okFinder);
          await tester.pumpAndSettle();

          final termForm = tester.widget<AcademicTermForm>(
            find.byType(AcademicTermForm),
          );
          termForm.onSave(
            name: 'Ganjil',
            startDate: DateTime(2025, 9),
            endDate: DateTime(2026, 1, 31),
          );

          verify(
            () => academicCalendarMutationBlocMock.add(
              AcademicCalendarTermCreateRequested(
                academicYearId: year.id,
                name: 'Ganjil',
                startDate: DateTime(2025, 9),
                endDate: DateTime(2026, 1, 31),
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'advances to Step 2 and shows AcademicCalendarEventForm when '
        'Lanjut ke Kegiatan is pressed',
        (tester) async {
          final controller = StreamController<AcademicCalendarMutationState>();
          addTearDown(controller.close);

          whenListen(
            academicCalendarMutationBlocMock,
            controller.stream,
            initialState: const AcademicCalendarMutationState(),
          );

          await pumpWidget(tester);

          controller.add(
            AcademicCalendarMutationState(
              notice: AcademicYearCreatedNotice(year),
            ),
          );
          await tester.pumpAndSettle();

          final okFinder = find.ancestor(
            of: find.text('OK'),
            matching: find.byType(AppButton),
          );
          await tester.tap(okFinder);
          await tester.pumpAndSettle();

          await tester.tap(find.text('Lanjut ke Kegiatan'));
          await tester.pumpAndSettle();

          expect(find.byType(AcademicCalendarEventForm), findsOneWidget);
          expect(
            find.text(
              'Kegiatan ini akan dimasukkan '
              'ke setiap kalender program studi. '
              'Jika ingin mengatur jadwal mata kuliah, '
              'gunakan fitur jadwal kuliah',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'dispatches AcademicCalendarEventCreateRequested when event form saves',
        (tester) async {
          final controller = StreamController<AcademicCalendarMutationState>();
          addTearDown(controller.close);

          whenListen(
            academicCalendarMutationBlocMock,
            controller.stream,
            initialState: const AcademicCalendarMutationState(),
          );

          await pumpWidget(tester);

          controller.add(
            AcademicCalendarMutationState(
              notice: AcademicYearCreatedNotice(year),
            ),
          );
          await tester.pumpAndSettle();

          final okFinder = find.ancestor(
            of: find.text('OK'),
            matching: find.byType(AppButton),
          );
          await tester.tap(okFinder);
          await tester.pumpAndSettle();

          await tester.tap(find.text('Lanjut ke Kegiatan'));
          await tester.pumpAndSettle();

          final eventForm = tester.widget<AcademicCalendarEventForm>(
            find.byType(AcademicCalendarEventForm),
          );
          eventForm.onSave(
            name: event.name,
            type: event.type,
            start: event.start,
            end: event.end,
          );

          verify(
            () => academicCalendarMutationBlocMock.add(
              AcademicCalendarEventCreateRequested(
                academicYearId: year.id,
                name: event.name,
                type: event.type,
                start: event.start,
                end: event.end,
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'calls onCalendarCreated with year, terms, and events when '
        'Selesai button is pressed in Step 2',
        (tester) async {
          final controller = StreamController<AcademicCalendarMutationState>();
          addTearDown(controller.close);

          whenListen(
            academicCalendarMutationBlocMock,
            controller.stream,
            initialState: const AcademicCalendarMutationState(),
          );

          AcademicCalendar? createdCalendar;
          await pumpWidget(
            tester,
            onCalendarCreated: (c) {
              createdCalendar = c;
            },
          );

          controller.add(
            AcademicCalendarMutationState(
              notice: AcademicYearCreatedNotice(year),
            ),
          );
          await tester.pumpAndSettle();

          var okFinder = find.ancestor(
            of: find.text('OK'),
            matching: find.byType(AppButton),
          );
          await tester.tap(okFinder);
          await tester.pumpAndSettle();

          controller.add(
            AcademicCalendarMutationState(
              notice: AcademicTermCreatedNotice(term),
            ),
          );
          await tester.pumpAndSettle();

          okFinder = find.ancestor(
            of: find.text('OK'),
            matching: find.byType(AppButton),
          );
          await tester.tap(okFinder);
          await tester.pumpAndSettle();

          await tester.tap(find.text('Lanjut ke Kegiatan'));
          await tester.pumpAndSettle();

          controller.add(
            AcademicCalendarMutationState(
              notice: AcademicCalendarEventCreatedNotice(event),
            ),
          );
          await tester.pumpAndSettle();

          okFinder = find.ancestor(
            of: find.text('OK'),
            matching: find.byType(AppButton),
          );
          await tester.tap(okFinder);
          await tester.pumpAndSettle();

          expect(find.byType(AcademicCalendarEventListTile), findsOneWidget);

          await tester.ensureVisible(find.text('Selesai'));
          await tester.tap(find.text('Selesai'));
          await tester.pumpAndSettle();

          expect(createdCalendar, isNotNull);
          expect(createdCalendar!.year, year);
          expect(createdCalendar!.terms, [term]);
          expect(createdCalendar!.events, [event]);
        },
      );
    });
  });
}
