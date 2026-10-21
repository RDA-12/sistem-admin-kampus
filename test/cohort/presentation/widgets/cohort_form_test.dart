import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late CohortMutationBloc cohortMutationBlocMock;

  group('CohortForm', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      cohortMutationBlocMock = getIt<CohortMutationBloc>();
      whenListen(
        cohortMutationBlocMock,
        Stream.value(const CohortMutationState()),
        initialState: const CohortMutationState(),
      );
    });

    Future<void> pumpWidget(
      WidgetTester tester, {
      Cohort? initial,
      void Function(Cohort)? onCohortDeleted,
    }) {
      return tester.pumpWidgetForTest(
        (context) => CohortForm(
          initial: initial,
          onCohortDeleted: onCohortDeleted,
        ),
        providerBuilder: (context, child) {
          return BlocProvider.value(
            value: cohortMutationBlocMock,
            child: child,
          );
        },
      );
    }

    final nameFieldFinder = find.ancestor(
      of: find.text('Nama Angkatan *'),
      matching: find.byType(TextFormField),
    );
    final entryYearFieldFinder = find.ancestor(
      of: find.text('Tahun Masuk *'),
      matching: find.byType(AppNumberFormField),
    );
    final saveButtonFinder = find.ancestor(
      of: find.text('Simpan'),
      matching: find.byType(AppButton),
    );
    final deleteButtonFinder = find.ancestor(
      of: find.text('Hapus'),
      matching: find.byType(AppButton),
    );

    group('Render', () {
      testWidgets('shows name and entryYear fields', (tester) async {
        await pumpWidget(tester);

        expect(nameFieldFinder, findsOneWidget);
        expect(entryYearFieldFinder, findsOneWidget);
      });

      testWidgets('shows save button', (tester) async {
        await pumpWidget(tester);

        expect(saveButtonFinder, findsOneWidget);
      });

      testWidgets(
        'shows LoadingIndicator and disable save button when '
        'CohortMutationState isCreating true',
        (tester) async {
          whenListen(
            cohortMutationBlocMock,
            Stream.value(const CohortMutationState(isCreating: true)),
          );

          await pumpWidget(tester);
          await tester.pump();

          expect(
            find.descendant(
              of: saveButtonFinder,
              matching: find.byType(LoadingIndicator),
            ),
            findsOneWidget,
          );
          expect(
            tester.widget<AppButton>(saveButtonFinder).onPressed,
            isNull,
          );
        },
      );

      testWidgets(
        'shows LoadingIndicator on save button and disable it '
        'when CohortMutationState updatingIds contains initial cohort',
        (tester) async {
          whenListen(
            cohortMutationBlocMock,
            Stream.value(CohortMutationState(updatingIds: {cohortMock.id})),
          );

          await pumpWidget(tester, initial: cohortMock);
          await tester.pump();

          expect(
            find.descendant(
              of: saveButtonFinder,
              matching: find.byType(LoadingIndicator),
            ),
            findsOneWidget,
          );
          expect(tester.widget<AppButton>(saveButtonFinder).onPressed, isNull);
        },
      );

      testWidgets(
        'disable delete button '
        'when CohortMutationState updatingIds contains initial cohort',
        (tester) async {
          whenListen(
            cohortMutationBlocMock,
            Stream.value(CohortMutationState(updatingIds: {cohortMock.id})),
          );

          await pumpWidget(tester, initial: cohortMock);
          await tester.pump();

          expect(
            tester.widget<AppButton>(deleteButtonFinder).onPressed,
            isNull,
          );
        },
      );

      testWidgets(
        'disable save button '
        'when CohortMutationState deletingIds contains initial cohort',
        (tester) async {
          whenListen(
            cohortMutationBlocMock,
            Stream.value(CohortMutationState(deletingIds: {cohortMock.id})),
          );

          await pumpWidget(tester, initial: cohortMock);
          await tester.pump();

          expect(
            tester.widget<AppButton>(saveButtonFinder).onPressed,
            isNull,
          );
        },
      );

      testWidgets(
        'shows LoadingIndicator on delete button and disable it '
        'when CohortMutationState deletingIds contains initial cohort',
        (tester) async {
          whenListen(
            cohortMutationBlocMock,
            Stream.value(CohortMutationState(deletingIds: {cohortMock.id})),
          );

          await pumpWidget(tester, initial: cohortMock);
          await tester.pump();

          expect(
            find.descendant(
              of: deleteButtonFinder,
              matching: find.byType(LoadingIndicator),
            ),
            findsOneWidget,
          );
          expect(
            tester.widget<AppButton>(deleteButtonFinder).onPressed,
            isNull,
          );
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'add CohortMutationCreateRequested when initial is null '
        'and save valid fields',
        (tester) async {
          await pumpWidget(tester);

          await tester.enterText(nameFieldFinder, 'Cohort 2025');
          await tester.enterText(entryYearFieldFinder, '2025');
          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          verify(
            () => cohortMutationBlocMock.add(
              const CohortMutationCreateRequested(
                name: 'Cohort 2025',
                entryYear: 2025,
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'add CohortMutationUpdateRequested when initial is provided '
        'and save valid fields',
        (tester) async {
          await pumpWidget(tester, initial: cohortMock);

          await tester.enterText(nameFieldFinder, 'Cohort 2026');
          await tester.enterText(entryYearFieldFinder, '2026');
          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          verify(
            () => cohortMutationBlocMock.add(
              const CohortMutationUpdateRequested(
                cohort: cohortMock,
                name: 'Cohort 2026',
                entryYear: 2026,
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'add CohortMutationDeleteRequested when delete button pressed',
        (tester) async {
          await pumpWidget(tester, initial: cohortMock);

          await tester.tap(deleteButtonFinder);
          await tester.pumpAndSettle();
          // Confirm on dialog
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();

          verify(
            () => cohortMutationBlocMock.add(
              const CohortMutationDeleteRequested(
                cohort: cohortMock,
              ),
            ),
          ).called(1);
        },
      );
    });

    group('Side Effects', () {
      testWidgets(
        'not clear fields when update success',
        (tester) async {
          final controller = StreamController<CohortMutationState>.broadcast();
          when(() => cohortMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester, initial: cohortMock);

          await tester.enterText(nameFieldFinder, 'Cohort 2099');
          await tester.enterText(entryYearFieldFinder, '2099');
          await tester.pumpAndSettle();

          final entryYearTextFieldFinder = find.descendant(
            of: entryYearFieldFinder,
            matching: find.byType(TextField),
          );

          expect(find.text('Cohort 2099'), findsOneWidget);
          expect(
            tester.widget<TextField>(entryYearTextFieldFinder).controller?.text,
            '2099',
          );

          controller.add(
            const CohortMutationState(
              notice: CohortUpdatedNotice(
                before: cohortMock,
                after: cohortMock,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Cohort 2099'), findsOneWidget);
          expect(
            tester.widget<TextField>(entryYearTextFieldFinder).controller?.text,
            '2099',
          );
        },
      );

      testWidgets('clear all fields when create success', (tester) async {
        final controller = StreamController<CohortMutationState>.broadcast();
        when(() => cohortMutationBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester);

        await tester.enterText(nameFieldFinder, 'Cohort 2025');
        await tester.enterText(entryYearFieldFinder, '2025');
        await tester.pumpAndSettle();

        final entryYearTextFieldFinder = find.descendant(
          of: entryYearFieldFinder,
          matching: find.byType(TextField),
        );

        expect(find.text('Cohort 2025'), findsOneWidget);
        expect(
          tester.widget<TextField>(entryYearTextFieldFinder).controller?.text,
          '2025',
        );

        controller.add(
          const CohortMutationState(
            notice: CohortCreatedNotice(cohortMock),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Cohort 2025'), findsNothing);
        expect(
          tester.widget<TextField>(entryYearTextFieldFinder).controller?.text,
          isEmpty,
        );
      });

      testWidgets(
        'shows success dialog with correct title and message '
        'when create success',
        (tester) async {
          final controller = StreamController<CohortMutationState>.broadcast();
          when(() => cohortMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            const CohortMutationState(
              notice: CohortCreatedNotice(cohortMock),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Angkatan berhasil disimpan'), findsOneWidget);
          expect(
            find.text(
              'Angkatan dengan nama "${cohortMock.name}" berhasil disimpan',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows success dialog with correct title and message '
        'when update success',
        (tester) async {
          const updated = Cohort(
            id: 'id',
            name: 'updated',
            entryYear: 2026,
          );
          final controller = StreamController<CohortMutationState>.broadcast();
          when(() => cohortMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);
          controller.add(
            const CohortMutationState(
              notice: CohortUpdatedNotice(before: cohortMock, after: updated),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Angkatan "${cohortMock.name}" berhasil diperbarui'),
            findsOneWidget,
          );
          expect(
            find.text(
              'Angkatan "${cohortMock.name}" berhasil diperbarui '
              'dengan nama "${updated.name}"',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows failed dialog with correct title and message when create failed',
        (tester) async {
          final controller = StreamController<CohortMutationState>.broadcast();
          when(() => cohortMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            CohortMutationState(
              notice: CohortMutationFailedNotice(
                type: CohortMutationType.create,
                exception: AppException.test(),
                cohort: null,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Gagal menyimpan angkatan baru'),
            findsOneWidget,
          );
          expect(
            find.text(AppExceptionCode.internal.message),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows failed dialog with correct title and message when update failed',
        (tester) async {
          final controller = StreamController<CohortMutationState>.broadcast();
          when(() => cohortMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            CohortMutationState(
              notice: CohortMutationFailedNotice(
                type: CohortMutationType.update,
                exception: AppException.test(),
                cohort: cohortMock,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Gagal memperbarui angkatan'),
            findsOneWidget,
          );
          expect(
            find.text(AppExceptionCode.internal.message),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows success dialog with correct title and message '
        'when delete success',
        (tester) async {
          final controller = StreamController<CohortMutationState>.broadcast();
          when(() => cohortMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);
          controller.add(
            const CohortMutationState(
              notice: CohortDeletedNotice(cohortMock),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Angkatan berhasil dihapus'), findsOneWidget);
          expect(
            find.text(
              'Angkatan dengan nama "${cohortMock.name}" berhasil dihapus',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows failed dialog with correct title and message when delete failed',
        (tester) async {
          final controller = StreamController<CohortMutationState>.broadcast();
          when(() => cohortMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            CohortMutationState(
              notice: CohortMutationFailedNotice(
                type: CohortMutationType.delete,
                exception: AppException.test(),
                cohort: cohortMock,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Gagal menghapus angkatan'),
            findsOneWidget,
          );
          expect(
            find.text(AppExceptionCode.internal.message),
            findsOneWidget,
          );
        },
      );
    });
  });
}
