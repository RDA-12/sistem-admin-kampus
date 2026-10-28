import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  final year = academicYearMock;
  final term = academicTermMock;
  late AcademicCalendarMutationBloc academicCalendarMutationBlocMock;

  group('AcademicTermForm', () {
    setUpAll(initializeMockDependencies);

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
      AcademicTerm? initial,
      void Function(AcademicTerm)? onAcademicTermDeleted,
      void Function(AcademicTerm)? onSaved,
    }) {
      return tester.pumpWidgetForTest(
        (context) => AcademicTermForm(
          academicYear: year,
          initial: initial,
          onAcademicTermDeleted: onAcademicTermDeleted,
          onSaved: onSaved,
        ),
        providerBuilder: (context, child) {
          return BlocProvider.value(
            value: academicCalendarMutationBlocMock,
            child: child,
          );
        },
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

    tearDown(() {
      reset(academicCalendarMutationBlocMock);
    });

    group('Render', () {
      testWidgets('shows all fields and save button', (tester) async {
        await pumpWidget(tester);

        expect(nameFieldFinder, findsOneWidget);
        expect(startDateFieldFinder, findsOneWidget);
        expect(endDateFieldFinder, findsOneWidget);
        expect(saveButtonFinder, findsOneWidget);
        expect(deleteButtonFinder, findsNothing);
      });

      testWidgets('shows delete button when initial is provided', (
        tester,
      ) async {
        await pumpWidget(tester, initial: term);

        expect(deleteButtonFinder, findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets(
        'adds AcademicCalendarTermCreateRequested when initial is null',
        (tester) async {
          await pumpWidget(tester);

          await tester.enterText(nameFieldFinder, 'Ganjil');
          await selectDate(tester, startDateFieldFinder, DateTime(2025, 9));
          await selectDate(tester, endDateFieldFinder, DateTime(2026, 1, 31));

          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

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
        'adds AcademicCalendarTermUpdateRequested when initial is provided',
        (tester) async {
          await pumpWidget(tester, initial: term);

          await tester.enterText(nameFieldFinder, 'Genap');
          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          verify(
            () => academicCalendarMutationBlocMock.add(
              AcademicCalendarTermUpdateRequested(
                academicTerm: term,
                name: 'Genap',
                startDate: term.startDate,
                endDate: term.endDate,
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'adds AcademicCalendarTermDeleteRequested when delete confirmed',
        (tester) async {
          await pumpWidget(tester, initial: term);

          await tester.tap(deleteButtonFinder);
          await tester.pumpAndSettle();

          final confirmFinder = find.ancestor(
            of: find.text('OK'),
            matching: find.byType(AppButton),
          );

          await tester.tap(confirmFinder);
          await tester.pumpAndSettle();

          verify(
            () => academicCalendarMutationBlocMock.add(
              AcademicCalendarTermDeleteRequested(academicTerm: term),
            ),
          ).called(1);
        },
      );
    });

    group('Side Effects', () {
      testWidgets('calls onSaved when create success', (tester) async {
        final controller = StreamController<AcademicCalendarMutationState>();
        addTearDown(controller.close);

        whenListen(
          academicCalendarMutationBlocMock,
          controller.stream,
          initialState: const AcademicCalendarMutationState(),
        );

        AcademicTerm? savedTerm;
        await pumpWidget(
          tester,
          onSaved: (t) {
            savedTerm = t;
          },
        );

        await tester.enterText(nameFieldFinder, 'Ganjil');
        await selectDate(tester, startDateFieldFinder, DateTime(2025, 9));
        await selectDate(tester, endDateFieldFinder, DateTime(2026, 1, 31));

        controller.add(
          AcademicCalendarMutationState(
            notice: AcademicTermCreatedNotice(term),
          ),
        );
        await tester.pumpAndSettle();

        final okFinder = find.ancestor(
          of: find.text('OK'),
          matching: find.byType(AppButton),
        );
        await tester.tap(okFinder);
        await tester.pumpAndSettle();

        expect(savedTerm, equals(term));
      });

      testWidgets('calls onSaved when update success', (tester) async {
        final controller = StreamController<AcademicCalendarMutationState>();
        addTearDown(controller.close);

        whenListen(
          academicCalendarMutationBlocMock,
          controller.stream,
          initialState: const AcademicCalendarMutationState(),
        );

        AcademicTerm? savedTerm;
        await pumpWidget(
          tester,
          initial: term,
          onSaved: (t) {
            savedTerm = t;
          },
        );

        controller.add(
          AcademicCalendarMutationState(
            notice: AcademicTermUpdatedNotice(
              before: term,
              after: term,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final okFinder = find.ancestor(
          of: find.text('OK'),
          matching: find.byType(AppButton),
        );
        await tester.tap(okFinder);
        await tester.pumpAndSettle();

        expect(savedTerm, equals(term));
      });

      testWidgets('shows failed dialog when mutation fails', (tester) async {
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
            notice: AcademicCalendarMutationFailedNotice(
              type: AcademicCalendarMutationType.create,
              target: AcademicCalendarTargetType.term,
              exception: AppException.test(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Gagal menyimpan semester baru'), findsOneWidget);
      });

      testWidgets('calls onAcademicTermDeleted when delete success', (
        tester,
      ) async {
        final controller = StreamController<AcademicCalendarMutationState>();
        addTearDown(controller.close);

        whenListen(
          academicCalendarMutationBlocMock,
          controller.stream,
          initialState: const AcademicCalendarMutationState(),
        );

        AcademicTerm? deletedTerm;
        await pumpWidget(
          tester,
          initial: term,
          onAcademicTermDeleted: (t) {
            deletedTerm = t;
          },
        );

        controller.add(
          AcademicCalendarMutationState(
            notice: AcademicTermDeletedNotice(term),
          ),
        );
        await tester.pumpAndSettle();

        final okFinder = find.ancestor(
          of: find.text('OK'),
          matching: find.byType(AppButton),
        );
        await tester.tap(okFinder);
        await tester.pumpAndSettle();

        expect(deletedTerm, equals(term));
      });
    });
  });
}
