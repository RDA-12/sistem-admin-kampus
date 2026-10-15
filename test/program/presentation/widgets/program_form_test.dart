import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../../faculty/domain/mocks.dart';
import '../../domain/mocks.dart';

void main() {
  final program = programUIMock;
  late ProgramMutationBloc programMutationBlocMock;
  late FacultiesBloc facultiesBlocMock;

  group('ProgramForm', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      programMutationBlocMock = getIt<ProgramMutationBloc>();
      whenListen(
        programMutationBlocMock,
        Stream.value(const ProgramMutationState()),
        initialState: const ProgramMutationState(),
      );

      facultiesBlocMock = getIt<FacultiesBloc>();
      whenListen(
        facultiesBlocMock,
        Stream.value(FacultiesLoaded(facultiesMock)),
        initialState: FacultiesLoaded(facultiesMock),
      );
    });

    Future<void> pumpWidget(
      WidgetTester tester, {
      ProgramUI? initial,
      void Function(Program)? onProgramDeleted,
    }) {
      return tester.pumpWidgetForTest(
        (context) => ProgramForm(
          initial: initial,
          onProgramDeleted: onProgramDeleted,
        ),
        providerBuilder: (context, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: programMutationBlocMock,
              ),
              BlocProvider.value(
                value: facultiesBlocMock,
              ),
            ],
            child: child,
          );
        },
      );
    }

    final facultySelectorFinder = find.ancestor(
      of: find.text('Fakultas *'),
      matching: find.byType(FacultySelector),
    );
    Future<void> selectFaculty(WidgetTester tester) async {
      await tester.tap(facultySelectorFinder);
      await tester.pumpAndSettle();
      final firstFinder = find.ancestor(
        of: find.text(facultiesMock.first.name),
        matching: find.byType(CheckboxListTile),
      );
      await tester.ensureVisible(firstFinder);
      await tester.tap(firstFinder);
      await tester.pumpAndSettle();
    }

    final nameFieldFinder = find.ancestor(
      of: find.text('Nama Program Studi *'),
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
      testWidgets('shows Fakultas selector and name fields', (tester) async {
        await pumpWidget(tester);

        expect(facultySelectorFinder, findsOneWidget);
        expect(nameFieldFinder, findsOneWidget);
      });

      testWidgets('shows save button', (tester) async {
        await pumpWidget(tester);

        expect(saveButtonFinder, findsOneWidget);
      });

      testWidgets(
        'shows LoadingIndicator and disable save button when '
        'ProgramMutationState isCreating true',
        (tester) async {
          whenListen(
            programMutationBlocMock,
            Stream.value(const ProgramMutationState(isCreating: true)),
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
        'when ProgramMutationState updatingIds contains initial program',
        (tester) async {
          whenListen(
            programMutationBlocMock,
            Stream.value(ProgramMutationState(updatingIds: {program.id})),
          );

          await pumpWidget(tester, initial: program);
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
        'when ProgramMutationState updatingIds contains initial program',
        (tester) async {
          whenListen(
            programMutationBlocMock,
            Stream.value(ProgramMutationState(deletingIds: {program.id})),
          );

          await pumpWidget(tester, initial: program);
          await tester.pump();

          expect(
            tester.widget<AppButton>(deleteButtonFinder).onPressed,
            isNull,
          );
        },
      );

      testWidgets(
        'disable save button '
        'when ProgramMutationState deletingIds contains initial program',
        (tester) async {
          whenListen(
            programMutationBlocMock,
            Stream.value(ProgramMutationState(deletingIds: {program.id})),
          );

          await pumpWidget(tester, initial: program);
          await tester.pump();

          expect(
            tester.widget<AppButton>(saveButtonFinder).onPressed,
            isNull,
          );
        },
      );

      testWidgets(
        'shows LoadingIndicator on delete button and disable it '
        'when ProgramMutationState deletingIds contains initial program',
        (tester) async {
          whenListen(
            programMutationBlocMock,
            Stream.value(ProgramMutationState(deletingIds: {program.id})),
          );

          await pumpWidget(tester, initial: program);
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
        'add ProgramMutationCreateRequested when initial is null '
        'and save valid fields',
        (tester) async {
          await pumpWidget(tester);

          await selectFaculty(tester);
          await tester.enterText(nameFieldFinder, 'Ilmu Komputer');
          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          verify(
            () => programMutationBlocMock.add(
              ProgramMutationCreateRequested(
                facultyId: facultiesMock.first.id,
                name: 'Ilmu Komputer',
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'add ProgramMutationUpdateRequested when initial is provided '
        'and save valid fields',
        (tester) async {
          await pumpWidget(tester, initial: program);

          await tester.enterText(nameFieldFinder, 'Teknik Informatika');
          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          verify(
            () => programMutationBlocMock.add(
              ProgramMutationUpdateRequested(
                program: program,
                name: 'Teknik Informatika',
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'add ProgramMutationDeleteRequested when delete button pressed',
        (tester) async {
          await pumpWidget(tester, initial: program);

          await tester.tap(deleteButtonFinder);
          await tester.pumpAndSettle();
          // Confirm on dialog
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();

          verify(
            () => programMutationBlocMock.add(
              ProgramMutationDeleteRequested(
                program: program,
              ),
            ),
          ).called(1);
        },
      );
    });

    group('Side Effects', () {
      testWidgets('not clear name and selector field when update success', (
        tester,
      ) async {
        final controller = StreamController<ProgramMutationState>.broadcast();
        when(() => programMutationBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester, initial: program);

        await selectFaculty(tester);
        await tester.enterText(nameFieldFinder, 'text');
        await tester.pumpAndSettle();

        expect(find.text(facultiesMock.first.name), findsOneWidget);
        expect(find.text('text'), findsOneWidget);

        controller.add(
          ProgramMutationState(
            notice: ProgramUpdatedNotice(before: program, after: program),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(facultiesMock.first.name), findsOneWidget);
        expect(find.text('text'), findsOneWidget);
      });

      testWidgets('clear all fields when create success', (tester) async {
        final controller = StreamController<ProgramMutationState>.broadcast();
        when(() => programMutationBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester);

        await selectFaculty(tester);
        await tester.enterText(nameFieldFinder, 'Ilmu Komputer');
        await tester.pumpAndSettle();

        expect(find.text(facultiesMock.first.name), findsOneWidget);
        expect(find.text('Ilmu Komputer'), findsOneWidget);

        controller.add(
          ProgramMutationState(
            notice: ProgramCreatedNotice(program),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(facultiesMock.first.name), findsNothing);
        expect(find.text('Ilmu Komputer'), findsNothing);
      });

      testWidgets(
        'shows success dialog with correct title and message when create '
        'success',
        (tester) async {
          final controller = StreamController<ProgramMutationState>.broadcast();
          when(() => programMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            ProgramMutationState(
              notice: ProgramCreatedNotice(program),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Program studi berhasil disimpan'), findsOneWidget);
          expect(
            find.text(
              'Program studi dengan nama "${program.name}" berhasil disimpan',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows success dialog with correct title and message when update '
        'success',
        (tester) async {
          const updated = Program(
            id: 'id',
            facultyId: 'faculty_1',
            name: 'updated',
          );
          final controller = StreamController<ProgramMutationState>.broadcast();
          when(() => programMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);
          controller.add(
            ProgramMutationState(
              notice: ProgramUpdatedNotice(before: program, after: updated),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Program studi "${program.name}" berhasil diperbarui'),
            findsOneWidget,
          );
          expect(
            find.text(
              'Program studi "${program.name}" berhasil diperbarui '
              'dengan nama "${updated.name}"',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows failed dialog with correct title and message when create failed',
        (tester) async {
          final controller = StreamController<ProgramMutationState>.broadcast();
          when(() => programMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            ProgramMutationState(
              notice: ProgramMutationFailedNotice(
                type: ProgramMutationType.create,
                exception: AppException.test(),
                program: null,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Gagal menyimpan program studi baru'),
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
          final controller = StreamController<ProgramMutationState>.broadcast();
          when(() => programMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            ProgramMutationState(
              notice: ProgramMutationFailedNotice(
                type: ProgramMutationType.update,
                exception: AppException.test(),
                program: program,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Gagal memperbarui program studi'),
            findsOneWidget,
          );
          expect(
            find.text(AppExceptionCode.internal.message),
            findsOneWidget,
          );
        },
      );

      testWidgets('shows success dialog with correct title and message '
          'when delete success', (tester) async {
        final controller = StreamController<ProgramMutationState>.broadcast();
        when(() => programMutationBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester);
        controller.add(
          ProgramMutationState(
            notice: ProgramDeletedNotice(program),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Program studi berhasil dihapus'), findsOneWidget);
        expect(
          find.text(
            'Program studi dengan nama "${program.name}" berhasil dihapus',
          ),
          findsOneWidget,
        );
      });

      testWidgets(
        'shows failed dialog with correct title and message when delete failed',
        (tester) async {
          final controller = StreamController<ProgramMutationState>.broadcast();
          when(() => programMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            ProgramMutationState(
              notice: ProgramMutationFailedNotice(
                type: ProgramMutationType.delete,
                exception: AppException.test(),
                program: program,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Gagal menghapus program studi'),
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
