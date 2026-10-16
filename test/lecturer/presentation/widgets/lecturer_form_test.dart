import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../../program/domain/mocks.dart';
import '../../domain/mocks.dart';

void main() {
  final lecturer = lecturerUIMock;
  late LecturerMutationBloc lecturerMutationBlocMock;
  late ProgramsBloc programsBlocMock;

  group('LecturerForm', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      lecturerMutationBlocMock = getIt<LecturerMutationBloc>();
      whenListen(
        lecturerMutationBlocMock,
        Stream.value(const LecturerMutationState()),
        initialState: const LecturerMutationState(),
      );

      programsBlocMock = getIt<ProgramsBloc>();
      whenListen(
        programsBlocMock,
        Stream.value(ProgramsLoaded(programsUIMock)),
        initialState: ProgramsLoaded(programsUIMock),
      );
    });

    Future<void> pumpWidget(
      WidgetTester tester, {
      LecturerUI? initial,
      void Function(Lecturer)? onLecturerDeleted,
    }) {
      return tester.pumpWidgetForTest(
        (context) => LecturerForm(
          initial: initial,
          onLecturerDeleted: onLecturerDeleted,
        ),
        providerBuilder: (context, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: lecturerMutationBlocMock,
              ),
              BlocProvider.value(
                value: programsBlocMock,
              ),
            ],
            child: child,
          );
        },
      );
    }

    final programSelectorFinder = find.ancestor(
      of: find.text('Program Studi *'),
      matching: find.byType(ProgramSelector),
    );
    Future<void> selectProgram(WidgetTester tester) async {
      await tester.tap(programSelectorFinder);
      await tester.pumpAndSettle();
      final firstFinder = find.ancestor(
        of: find.text(programsMock.first.name),
        matching: find.byType(CheckboxListTile),
      );
      await tester.ensureVisible(firstFinder);
      await tester.tap(firstFinder);
      await tester.pumpAndSettle();
    }

    final nameFieldFinder = find.ancestor(
      of: find.text('Nama Dosen *'),
      matching: find.byType(TextFormField),
    );
    final pangkatGolonganFieldFinder = find.ancestor(
      of: find.text('Pangkat / Golongan *'),
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

    group('Render', () {
      testWidgets('shows Program Studi selector, name, and pangkat fields', (
        tester,
      ) async {
        await pumpWidget(tester);

        expect(programSelectorFinder, findsOneWidget);
        expect(nameFieldFinder, findsOneWidget);
        expect(pangkatGolonganFieldFinder, findsOneWidget);
      });

      testWidgets('shows save button', (tester) async {
        await pumpWidget(tester);

        expect(saveButtonFinder, findsOneWidget);
      });

      testWidgets(
        'shows LoadingIndicator and disable save button when '
        'LecturerMutationState isCreating true',
        (tester) async {
          whenListen(
            lecturerMutationBlocMock,
            Stream.value(const LecturerMutationState(isCreating: true)),
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
        'when LecturerMutationState updatingIds contains initial lecturer',
        (tester) async {
          whenListen(
            lecturerMutationBlocMock,
            Stream.value(LecturerMutationState(updatingIds: {lecturer.id})),
          );

          await pumpWidget(tester, initial: lecturer);
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
        'when LecturerMutationState updatingIds contains initial lecturer',
        (tester) async {
          whenListen(
            lecturerMutationBlocMock,
            Stream.value(LecturerMutationState(deletingIds: {lecturer.id})),
          );

          await pumpWidget(tester, initial: lecturer);
          await tester.pump();

          expect(
            tester.widget<AppButton>(deleteButtonFinder).onPressed,
            isNull,
          );
        },
      );

      testWidgets(
        'disable save button '
        'when LecturerMutationState deletingIds contains initial lecturer',
        (tester) async {
          whenListen(
            lecturerMutationBlocMock,
            Stream.value(LecturerMutationState(deletingIds: {lecturer.id})),
          );

          await pumpWidget(tester, initial: lecturer);
          await tester.pump();

          expect(
            tester.widget<AppButton>(saveButtonFinder).onPressed,
            isNull,
          );
        },
      );

      testWidgets(
        'shows LoadingIndicator on delete button and disable it '
        'when LecturerMutationState deletingIds contains initial lecturer',
        (tester) async {
          whenListen(
            lecturerMutationBlocMock,
            Stream.value(LecturerMutationState(deletingIds: {lecturer.id})),
          );

          await pumpWidget(tester, initial: lecturer);
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
        'add LecturerMutationCreateRequested when initial is null '
        'and save valid fields',
        (tester) async {
          await pumpWidget(tester);

          await selectProgram(tester);
          await tester.enterText(nameFieldFinder, 'Dr. Budi');
          await tester.enterText(pangkatGolonganFieldFinder, 'IV/a');
          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          verify(
            () => lecturerMutationBlocMock.add(
              LecturerMutationCreateRequested(
                programId: programsMock.first.id,
                name: 'Dr. Budi',
                pangkatGolongan: 'IV/a',
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'add LecturerMutationUpdateRequested when initial is provided '
        'and save valid fields',
        (tester) async {
          await pumpWidget(tester, initial: lecturer);

          await tester.enterText(nameFieldFinder, 'Dr. Budi Baru');
          await tester.enterText(pangkatGolonganFieldFinder, 'IV/b');
          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          verify(
            () => lecturerMutationBlocMock.add(
              LecturerMutationUpdateRequested(
                lecturer: lecturer,
                name: 'Dr. Budi Baru',
                pangkatGolongan: 'IV/b',
                programId: lecturer.programId,
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'add LecturerMutationDeleteRequested when delete button pressed',
        (tester) async {
          await pumpWidget(tester, initial: lecturer);

          await tester.tap(deleteButtonFinder);
          await tester.pumpAndSettle();
          // Confirm on dialog
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();

          verify(
            () => lecturerMutationBlocMock.add(
              LecturerMutationDeleteRequested(
                lecturer: lecturer,
              ),
            ),
          ).called(1);
        },
      );
    });

    group('Side Effects', () {
      testWidgets(
        'not clear name, pangkat, and selector field when update success',
        (
          tester,
        ) async {
          final controller =
              StreamController<LecturerMutationState>.broadcast();
          when(() => lecturerMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester, initial: lecturer);

          await selectProgram(tester);
          await tester.enterText(nameFieldFinder, 'text');
          await tester.enterText(pangkatGolonganFieldFinder, 'pangkat');
          await tester.pumpAndSettle();

          expect(find.text(programsMock.first.name), findsOneWidget);
          expect(find.text('text'), findsOneWidget);
          expect(find.text('pangkat'), findsOneWidget);

          controller.add(
            LecturerMutationState(
              notice: LecturerUpdatedNotice(before: lecturer, after: lecturer),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text(programsMock.first.name), findsOneWidget);
          expect(find.text('text'), findsOneWidget);
          expect(find.text('pangkat'), findsOneWidget);
        },
      );

      testWidgets('clear all fields when create success', (tester) async {
        final controller = StreamController<LecturerMutationState>.broadcast();
        when(() => lecturerMutationBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester);

        await selectProgram(tester);
        await tester.enterText(nameFieldFinder, 'Dr. Budi');
        await tester.enterText(pangkatGolonganFieldFinder, 'IV/a');
        await tester.pumpAndSettle();

        expect(find.text(programsMock.first.name), findsOneWidget);
        expect(find.text('Dr. Budi'), findsOneWidget);
        expect(find.text('IV/a'), findsOneWidget);

        controller.add(
          LecturerMutationState(
            notice: LecturerCreatedNotice(lecturer),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(programsMock.first.name), findsNothing);
        expect(find.text('Dr. Budi'), findsNothing);
        expect(find.text('IV/a'), findsNothing);
      });

      testWidgets(
        'shows success dialog with correct title and message when create '
        'success',
        (tester) async {
          final controller =
              StreamController<LecturerMutationState>.broadcast();
          when(() => lecturerMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            LecturerMutationState(
              notice: LecturerCreatedNotice(lecturer),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Dosen berhasil disimpan'), findsOneWidget);
          expect(
            find.text(
              'Dosen dengan nama "${lecturer.name}" berhasil disimpan',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows success dialog with correct title and message when update '
        'success',
        (tester) async {
          const updated = Lecturer(
            id: 'id',
            programId: 'program_1',
            name: 'updated',
            pangkatGolongan: 'IV/b',
          );
          final controller =
              StreamController<LecturerMutationState>.broadcast();
          when(() => lecturerMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);
          controller.add(
            LecturerMutationState(
              notice: LecturerUpdatedNotice(before: lecturer, after: updated),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Dosen "${lecturer.name}" berhasil diperbarui'),
            findsOneWidget,
          );
          expect(
            find.text(
              'Dosen "${lecturer.name}" berhasil diperbarui '
              'dengan nama "${updated.name}"',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows failed dialog with correct title and message when create failed',
        (tester) async {
          final controller =
              StreamController<LecturerMutationState>.broadcast();
          when(() => lecturerMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            LecturerMutationState(
              notice: LecturerMutationFailedNotice(
                type: LecturerMutationType.create,
                exception: AppException.test(),
                lecturer: null,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Gagal menyimpan dosen baru'),
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
          final controller =
              StreamController<LecturerMutationState>.broadcast();
          when(() => lecturerMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            LecturerMutationState(
              notice: LecturerMutationFailedNotice(
                type: LecturerMutationType.update,
                exception: AppException.test(),
                lecturer: lecturer,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Gagal memperbarui dosen'),
            findsOneWidget,
          );
          expect(
            find.text(AppExceptionCode.internal.message),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows success dialog with correct title and message when delete '
        'success',
        (tester) async {
          final controller =
              StreamController<LecturerMutationState>.broadcast();
          when(() => lecturerMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);
          controller.add(
            LecturerMutationState(
              notice: LecturerDeletedNotice(lecturer),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Dosen berhasil dihapus'), findsOneWidget);
          expect(
            find.text(
              'Dosen dengan nama "${lecturer.name}" berhasil dihapus',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows failed dialog with correct title and message when delete failed',
        (tester) async {
          final controller =
              StreamController<LecturerMutationState>.broadcast();
          when(() => lecturerMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            LecturerMutationState(
              notice: LecturerMutationFailedNotice(
                type: LecturerMutationType.delete,
                exception: AppException.test(),
                lecturer: lecturer,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Gagal menghapus dosen'),
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
