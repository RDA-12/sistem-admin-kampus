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
import '../../domain/mocks.dart';

void main() {
  final year = academicYearMock;
  final term = academicTermMock;
  late AcademicTermMutationBloc academicTermMutationBlocMock;

  group('AcademicTermForm', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      academicTermMutationBlocMock = getIt<AcademicTermMutationBloc>();
      whenListen(
        academicTermMutationBlocMock,
        Stream.value(const AcademicTermMutationState()),
        initialState: const AcademicTermMutationState(),
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
            value: academicTermMutationBlocMock,
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
      reset(academicTermMutationBlocMock);
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
        'adds AcademicTermMutationCreateRequested when initial is null',
        (tester) async {
          await pumpWidget(tester);

          await tester.enterText(nameFieldFinder, 'Ganjil');
          await tester.enterText(startDateFieldFinder, '2025-09-01');
          await tester.enterText(endDateFieldFinder, '2026-01-31');

          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          verify(
            () => academicTermMutationBlocMock.add(
              AcademicTermMutationCreateRequested(
                academicYearId: year.id,
                name: 'Ganjil',
                startDate: DateTime.parse('2025-09-01'),
                endDate: DateTime.parse('2026-01-31'),
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'adds AcademicTermMutationUpdateRequested when initial is provided',
        (tester) async {
          await pumpWidget(tester, initial: term);

          await tester.enterText(nameFieldFinder, 'Genap');
          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          verify(
            () => academicTermMutationBlocMock.add(
              AcademicTermMutationUpdateRequested(
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
        'adds AcademicTermMutationDeleteRequested when delete confirmed',
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
            () => academicTermMutationBlocMock.add(
              AcademicTermMutationDeleteRequested(academicTerm: term),
            ),
          ).called(1);
        },
      );
    });

    group('Side Effects', () {
      testWidgets('calls onSaved when create success', (tester) async {
        final controller = StreamController<AcademicTermMutationState>();
        addTearDown(controller.close);

        whenListen(
          academicTermMutationBlocMock,
          controller.stream,
          initialState: const AcademicTermMutationState(),
        );

        AcademicTerm? savedTerm;
        await pumpWidget(
          tester,
          onSaved: (t) {
            savedTerm = t;
          },
        );

        await tester.enterText(nameFieldFinder, 'Ganjil');
        await tester.enterText(startDateFieldFinder, '2025-09-01');
        await tester.enterText(endDateFieldFinder, '2026-01-31');

        controller.add(
          AcademicTermMutationState(
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
        final controller = StreamController<AcademicTermMutationState>();
        addTearDown(controller.close);

        whenListen(
          academicTermMutationBlocMock,
          controller.stream,
          initialState: const AcademicTermMutationState(),
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
          AcademicTermMutationState(
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
        final controller = StreamController<AcademicTermMutationState>();
        addTearDown(controller.close);

        whenListen(
          academicTermMutationBlocMock,
          controller.stream,
          initialState: const AcademicTermMutationState(),
        );

        await pumpWidget(tester);

        controller.add(
          AcademicTermMutationState(
            notice: AcademicTermMutationFailedNotice(
              type: AcademicTermMutationType.create,
              exception: AppException.test(),
              academicTerm: null,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Gagal menyimpan semester baru'), findsOneWidget);
      });

      testWidgets('calls onAcademicTermDeleted when delete success', (
        tester,
      ) async {
        final controller = StreamController<AcademicTermMutationState>();
        addTearDown(controller.close);

        whenListen(
          academicTermMutationBlocMock,
          controller.stream,
          initialState: const AcademicTermMutationState(),
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
          AcademicTermMutationState(
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
