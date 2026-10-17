import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';

void main() {
  final year = AcademicYear(
    id: 'id',
    name: '2025/2026',
    startDate: DateTime(2025, 9),
    endDate: DateTime(2026, 8, 31),
  );
  late AcademicYearMutationBloc academicYearMutationBlocMock;

  group('AcademicYearForm', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      academicYearMutationBlocMock = getIt<AcademicYearMutationBloc>();
      whenListen(
        academicYearMutationBlocMock,
        Stream.value(const AcademicYearMutationState()),
        initialState: const AcademicYearMutationState(),
      );
    });

    Future<void> pumpWidget(
      WidgetTester tester, {
      AcademicYear? initial,
      void Function(AcademicYear)? onAcademicYearDeleted,
    }) {
      return tester.pumpWidgetForTest(
        (context) => AcademicYearForm(
          initial: initial,
          onAcademicYearDeleted: onAcademicYearDeleted,
        ),
        providerBuilder: (context, child) {
          return BlocProvider.value(
            value: academicYearMutationBlocMock,
            child: child,
          );
        },
      );
    }

    final nameFieldFinder = find.ancestor(
      of: find.text('Nama Tahun Akademik *'),
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
    final saveButtonFinder = find.ancestor(
      of: find.text('Simpan'),
      matching: find.byType(AppButton),
    );
    final deleteButtonFinder = find.ancestor(
      of: find.text('Hapus'),
      matching: find.byType(AppButton),
    );

    tearDown(() {
      reset(academicYearMutationBlocMock);
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
        await pumpWidget(tester, initial: year);

        expect(deleteButtonFinder, findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets(
        'adds AcademicYearMutationCreateRequested when initial is null',
        (tester) async {
          await pumpWidget(tester);

          await tester.enterText(nameFieldFinder, '2025/2026');
          await tester.enterText(startDateFieldFinder, '2025-09-01');
          await tester.enterText(endDateFieldFinder, '2026-08-31');

          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          verify(
            () => academicYearMutationBlocMock.add(
              AcademicYearMutationCreateRequested(
                name: '2025/2026',
                startDate: DateTime.parse('2025-09-01'),
                endDate: DateTime.parse('2026-08-31'),
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'adds AcademicYearMutationUpdateRequested when initial is provided',
        (tester) async {
          await pumpWidget(tester, initial: year);

          await tester.enterText(nameFieldFinder, '2026/2027');
          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          verify(
            () => academicYearMutationBlocMock.add(
              AcademicYearMutationUpdateRequested(
                academicYear: year,
                name: '2026/2027',
                startDate: year.startDate,
                endDate: year.endDate,
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'adds AcademicYearMutationDeleteRequested when delete confirmed',
        (tester) async {
          await pumpWidget(tester, initial: year);

          await tester.tap(deleteButtonFinder);
          await tester.pumpAndSettle();

          final confirmFinder = find.ancestor(
            of: find.text('OK'),
            matching: find.byType(AppButton),
          );

          await tester.tap(confirmFinder);
          await tester.pumpAndSettle();

          verify(
            () => academicYearMutationBlocMock.add(
              AcademicYearMutationDeleteRequested(academicYear: year),
            ),
          ).called(1);
        },
      );
    });

    group('Side Effects', () {
      testWidgets('clears all fields when create success', (tester) async {
        final controller = StreamController<AcademicYearMutationState>();
        addTearDown(controller.close);

        whenListen(
          academicYearMutationBlocMock,
          controller.stream,
          initialState: const AcademicYearMutationState(),
        );

        await pumpWidget(tester);

        await tester.enterText(nameFieldFinder, '2025/2026');
        await tester.enterText(startDateFieldFinder, '2025-09-01');
        await tester.enterText(endDateFieldFinder, '2026-08-31');

        controller.add(
          AcademicYearMutationState(
            notice: AcademicYearCreatedNotice(year),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Tahun akademik berhasil disimpan'), findsOneWidget);
      });

      testWidgets('shows success dialog when update success', (tester) async {
        final controller = StreamController<AcademicYearMutationState>();
        addTearDown(controller.close);

        whenListen(
          academicYearMutationBlocMock,
          controller.stream,
          initialState: const AcademicYearMutationState(),
        );

        await pumpWidget(tester, initial: year);

        controller.add(
          AcademicYearMutationState(
            notice: AcademicYearUpdatedNotice(
              before: year,
              after: year,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Tahun akademik "${year.name}" berhasil diperbarui'),
          findsOneWidget,
        );
      });

      testWidgets('shows failed dialog when mutation fails', (tester) async {
        final controller = StreamController<AcademicYearMutationState>();
        addTearDown(controller.close);

        whenListen(
          academicYearMutationBlocMock,
          controller.stream,
          initialState: const AcademicYearMutationState(),
        );

        await pumpWidget(tester);

        controller.add(
          AcademicYearMutationState(
            notice: AcademicYearMutationFailedNotice(
              type: AcademicYearMutationType.create,
              exception: AppException.test(),
              academicYear: null,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Gagal menyimpan tahun akademik baru'),
          findsOneWidget,
        );
      });

      testWidgets('calls onAcademicYearDeleted when delete success', (
        tester,
      ) async {
        final controller = StreamController<AcademicYearMutationState>();
        addTearDown(controller.close);

        whenListen(
          academicYearMutationBlocMock,
          controller.stream,
          initialState: const AcademicYearMutationState(),
        );

        AcademicYear? deletedYear;
        await pumpWidget(
          tester,
          initial: year,
          onAcademicYearDeleted: (y) {
            deletedYear = y;
          },
        );

        controller.add(
          AcademicYearMutationState(
            notice: AcademicYearDeletedNotice(year),
          ),
        );
        await tester.pumpAndSettle();

        final okFinder = find.ancestor(
          of: find.text('OK'),
          matching: find.byType(AppButton),
        );
        await tester.tap(okFinder);
        await tester.pumpAndSettle();

        expect(deletedYear, equals(year));
      });
    });
  });
}
