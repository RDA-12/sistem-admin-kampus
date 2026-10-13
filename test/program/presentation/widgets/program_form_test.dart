import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';

void main() {
  const program = Program(id: 'id', facultyId: 'faculty_1', name: 'name');
  late ProgramMutationBloc programMutationBlocMock;

  group('ProgramForm', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      programMutationBlocMock = getIt<ProgramMutationBloc>();
      whenListen(
        programMutationBlocMock,
        Stream.value(const ProgramMutationState()),
        initialState: const ProgramMutationState(),
      );
    });

    Future<void> pumpWidget(
      WidgetTester tester, {
      Program? initial,
      void Function(Program)? onProgramDeleted,
    }) {
      return tester.pumpWidgetForTest(
        (context) => ProgramForm(
          initial: initial,
          onProgramDeleted: onProgramDeleted,
        ),
        providerBuilder: (context, child) {
          return BlocProvider.value(
            value: programMutationBlocMock,
            child: child,
          );
        },
      );
    }

    final facultyIdFieldFinder = find.ancestor(
      of: find.text('ID Fakultas *'),
      matching: find.byType(TextFormField),
    );
    final nameFieldFinder = find.ancestor(
      of: find.text('Nama Program Studi *'),
      matching: find.byType(TextFormField),
    );
    final saveButtonFinder = find.ancestor(
      of: find.text('Simpan'),
      matching: find.byType(AppButton),
    );

    group('Render', () {
      testWidgets('shows ID Fakultas and name fields', (tester) async {
        await pumpWidget(tester);

        expect(facultyIdFieldFinder, findsOneWidget);
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
    });

    group('Interactions', () {
      testWidgets(
        'add ProgramMutationCreateRequested when initial is null '
        'and save valid fields',
        (tester) async {
          await pumpWidget(tester);

          await tester.enterText(facultyIdFieldFinder, 'faculty_1');
          await tester.enterText(nameFieldFinder, 'Ilmu Komputer');
          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          verify(
            () => programMutationBlocMock.add(
              const ProgramMutationCreateRequested(
                facultyId: 'faculty_1',
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
              const ProgramMutationUpdateRequested(
                program: program,
                name: 'Teknik Informatika',
              ),
            ),
          ).called(1);
        },
      );
    });

    group('Side Effects', () {
      testWidgets('clear all fields when create success', (tester) async {
        final controller = StreamController<ProgramMutationState>.broadcast();
        when(() => programMutationBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester);

        await tester.enterText(facultyIdFieldFinder, 'faculty_1');
        await tester.enterText(nameFieldFinder, 'Ilmu Komputer');
        await tester.pumpAndSettle();

        expect(find.text('faculty_1'), findsOneWidget);
        expect(find.text('Ilmu Komputer'), findsOneWidget);

        controller.add(
          const ProgramMutationState(
            notice: ProgramCreatedNotice(program),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('faculty_1'), findsNothing);
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
            const ProgramMutationState(
              notice: ProgramCreatedNotice(program),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Program studi berhasil disimpan'), findsOneWidget);
          expect(
            find.text('Program studi dengan nama "name" berhasil disimpan'),
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
            const ProgramMutationState(
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
    });
  });
}
