import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../../program/domain/mocks.dart';
import '../../domain/mocks.dart';

void main() {
  final course = courseUIMock;
  late CourseMutationBloc courseMutationBlocMock;
  late ProgramsBloc programsBlocMock;

  group('CourseForm', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      courseMutationBlocMock = getIt<CourseMutationBloc>();
      whenListen(
        courseMutationBlocMock,
        Stream.value(const CourseMutationState()),
        initialState: const CourseMutationState(),
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
      CourseUI? initial,
      void Function(Course)? onCourseDeleted,
    }) {
      return tester.pumpWidgetForTest(
        (context) => CourseForm(
          initial: initial,
          onCourseDeleted: onCourseDeleted,
        ),
        providerBuilder: (context, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: courseMutationBlocMock,
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

    final codeFieldFinder = find.ancestor(
      of: find.text('Kode Mata Kuliah *'),
      matching: find.byType(TextFormField),
    );
    final nameFieldFinder = find.ancestor(
      of: find.text('Nama Mata Kuliah *'),
      matching: find.byType(TextFormField),
    );
    final semesterDropdownFinder = find.ancestor(
      of: find.text('Semester *'),
      matching: find.byType(SemesterDropdown),
    );
    Future<void> selectSemester(WidgetTester tester, int semester) async {
      await tester.tap(semesterDropdownFinder);
      await tester.pumpAndSettle();
      final optionFinder = find.descendant(
        of: find.byType(MenuItemButton),
        matching: find.text('$semester'),
      );
      await tester.tap(optionFinder.last);
      await tester.pumpAndSettle();
    }

    final creditFieldFinder = find.ancestor(
      of: find.text('Bobot SKS *'),
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
      testWidgets(
        'shows Program Studi selector, code, name, semester, and credit fields',
        (
          tester,
        ) async {
          await pumpWidget(tester);

          expect(programSelectorFinder, findsOneWidget);
          expect(codeFieldFinder, findsOneWidget);
          expect(nameFieldFinder, findsOneWidget);
          expect(semesterDropdownFinder, findsOneWidget);
          expect(creditFieldFinder, findsOneWidget);
        },
      );

      testWidgets('shows save button', (tester) async {
        await pumpWidget(tester);

        expect(saveButtonFinder, findsOneWidget);
      });

      testWidgets(
        'shows LoadingIndicator and disable save button when '
        'CourseMutationState isCreating true',
        (tester) async {
          whenListen(
            courseMutationBlocMock,
            Stream.value(const CourseMutationState(isCreating: true)),
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
        'when CourseMutationState updatingIds contains initial course',
        (tester) async {
          whenListen(
            courseMutationBlocMock,
            Stream.value(CourseMutationState(updatingIds: {course.id})),
          );

          await pumpWidget(tester, initial: course);
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
        'when CourseMutationState updatingIds contains initial course',
        (tester) async {
          whenListen(
            courseMutationBlocMock,
            Stream.value(CourseMutationState(deletingIds: {course.id})),
          );

          await pumpWidget(tester, initial: course);
          await tester.pump();

          expect(
            tester.widget<AppButton>(deleteButtonFinder).onPressed,
            isNull,
          );
        },
      );

      testWidgets(
        'disable save button '
        'when CourseMutationState deletingIds contains initial course',
        (tester) async {
          whenListen(
            courseMutationBlocMock,
            Stream.value(CourseMutationState(deletingIds: {course.id})),
          );

          await pumpWidget(tester, initial: course);
          await tester.pump();

          expect(
            tester.widget<AppButton>(saveButtonFinder).onPressed,
            isNull,
          );
        },
      );

      testWidgets(
        'shows LoadingIndicator on delete button and disable it '
        'when CourseMutationState deletingIds contains initial course',
        (tester) async {
          whenListen(
            courseMutationBlocMock,
            Stream.value(CourseMutationState(deletingIds: {course.id})),
          );

          await pumpWidget(tester, initial: course);
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
        'add CourseMutationCreateRequested when initial is null '
        'and save valid fields',
        (tester) async {
          await pumpWidget(tester);

          await selectProgram(tester);
          await tester.enterText(codeFieldFinder, 'CS101');
          await tester.enterText(nameFieldFinder, 'Algoritma');
          await selectSemester(tester, 1);
          await tester.enterText(creditFieldFinder, '3');
          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          verify(
            () => courseMutationBlocMock.add(
              CourseMutationCreateRequested(
                programId: programsMock.first.id,
                code: 'CS101',
                name: 'Algoritma',
                semester: 1,
                credit: 3,
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'add CourseMutationUpdateRequested when initial is provided '
        'and save valid fields',
        (tester) async {
          await pumpWidget(tester, initial: course);

          await tester.enterText(codeFieldFinder, 'CS102');
          await tester.enterText(nameFieldFinder, 'Algoritma Lanjut');
          await selectSemester(tester, 2);
          await tester.enterText(creditFieldFinder, '4');
          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          verify(
            () => courseMutationBlocMock.add(
              CourseMutationUpdateRequested(
                course: course,
                code: 'CS102',
                name: 'Algoritma Lanjut',
                semester: 2,
                credit: 4,
                programId: course.programId,
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'add CourseMutationDeleteRequested when delete button pressed',
        (tester) async {
          await pumpWidget(tester, initial: course);

          await tester.tap(deleteButtonFinder);
          await tester.pumpAndSettle();
          // Confirm on dialog
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();

          verify(
            () => courseMutationBlocMock.add(
              CourseMutationDeleteRequested(
                course: course,
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
          final controller = StreamController<CourseMutationState>.broadcast();
          when(() => courseMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester, initial: course);

          await selectProgram(tester);
          await tester.enterText(codeFieldFinder, 'CS999');
          await tester.enterText(nameFieldFinder, 'Nama Baru');
          await selectSemester(tester, 3);
          await tester.enterText(creditFieldFinder, '2');
          await tester.pumpAndSettle();

          final semesterTextFieldFinder = find.descendant(
            of: semesterDropdownFinder,
            matching: find.byType(TextField),
          );
          final creditTextFieldFinder = find.descendant(
            of: creditFieldFinder,
            matching: find.byType(TextField),
          );

          expect(find.text(programsMock.first.name), findsOneWidget);
          expect(find.text('CS999'), findsOneWidget);
          expect(find.text('Nama Baru'), findsOneWidget);
          expect(
            tester.widget<TextField>(semesterTextFieldFinder).controller?.text,
            '3',
          );
          expect(
            tester.widget<TextField>(creditTextFieldFinder).controller?.text,
            '2',
          );

          controller.add(
            CourseMutationState(
              notice: CourseUpdatedNotice(before: course, after: course),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text(programsMock.first.name), findsOneWidget);
          expect(find.text('CS999'), findsOneWidget);
          expect(find.text('Nama Baru'), findsOneWidget);
          expect(
            tester.widget<TextField>(semesterTextFieldFinder).controller?.text,
            '3',
          );
          expect(
            tester.widget<TextField>(creditTextFieldFinder).controller?.text,
            '2',
          );
        },
      );

      testWidgets('clear all fields when create success', (tester) async {
        final controller = StreamController<CourseMutationState>.broadcast();
        when(() => courseMutationBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester);

        await selectProgram(tester);
        await tester.enterText(codeFieldFinder, 'CS101');
        await tester.enterText(nameFieldFinder, 'Algoritma');
        await selectSemester(tester, 1);
        await tester.enterText(creditFieldFinder, '3');
        await tester.pumpAndSettle();

        final semesterTextFieldFinder = find.descendant(
          of: semesterDropdownFinder,
          matching: find.byType(TextField),
        );
        final creditTextFieldFinder = find.descendant(
          of: creditFieldFinder,
          matching: find.byType(TextField),
        );

        expect(find.text(programsMock.first.name), findsOneWidget);
        expect(find.text('CS101'), findsOneWidget);
        expect(find.text('Algoritma'), findsOneWidget);
        expect(
          tester.widget<TextField>(semesterTextFieldFinder).controller?.text,
          '1',
        );
        expect(
          tester.widget<TextField>(creditTextFieldFinder).controller?.text,
          '3',
        );

        controller.add(
          CourseMutationState(
            notice: CourseCreatedNotice(course),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(programsMock.first.name), findsNothing);
        expect(find.text('CS101'), findsNothing);
        expect(find.text('Algoritma'), findsNothing);
        expect(
          tester.widget<TextField>(semesterTextFieldFinder).controller?.text,
          isEmpty,
        );
        expect(
          tester.widget<TextField>(creditTextFieldFinder).controller?.text,
          isEmpty,
        );
      });

      testWidgets(
        'shows success dialog with correct title and message '
        'when create success',
        (tester) async {
          final controller = StreamController<CourseMutationState>.broadcast();
          when(() => courseMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            CourseMutationState(
              notice: CourseCreatedNotice(course),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Mata kuliah berhasil disimpan'), findsOneWidget);
          expect(
            find.text(
              'Mata kuliah dengan nama "${course.name}" berhasil disimpan',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows success dialog with correct title and message '
        'when update success',
        (tester) async {
          const updated = Course(
            id: 'id',
            programId: 'program_1',
            code: 'CS102',
            name: 'updated',
            semester: 2,
            credit: 4,
          );
          final controller = StreamController<CourseMutationState>.broadcast();
          when(() => courseMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);
          controller.add(
            CourseMutationState(
              notice: CourseUpdatedNotice(before: course, after: updated),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Mata kuliah "${course.name}" berhasil diperbarui'),
            findsOneWidget,
          );
          expect(
            find.text(
              'Mata kuliah "${course.name}" berhasil diperbarui '
              'dengan nama "${updated.name}"',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows failed dialog with correct title and message when create failed',
        (tester) async {
          final controller = StreamController<CourseMutationState>.broadcast();
          when(() => courseMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            CourseMutationState(
              notice: CourseMutationFailedNotice(
                type: CourseMutationType.create,
                exception: AppException.test(),
                course: null,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Gagal menyimpan mata kuliah baru'),
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
          final controller = StreamController<CourseMutationState>.broadcast();
          when(() => courseMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            CourseMutationState(
              notice: CourseMutationFailedNotice(
                type: CourseMutationType.update,
                exception: AppException.test(),
                course: course,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Gagal memperbarui mata kuliah'),
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
          final controller = StreamController<CourseMutationState>.broadcast();
          when(() => courseMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);
          controller.add(
            CourseMutationState(
              notice: CourseDeletedNotice(course),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Mata kuliah berhasil dihapus'), findsOneWidget);
          expect(
            find.text(
              'Mata kuliah dengan nama "${course.name}" berhasil dihapus',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows failed dialog with correct title and message when delete failed',
        (tester) async {
          final controller = StreamController<CourseMutationState>.broadcast();
          when(() => courseMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            CourseMutationState(
              notice: CourseMutationFailedNotice(
                type: CourseMutationType.delete,
                exception: AppException.test(),
                course: course,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Gagal menghapus mata kuliah'),
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
