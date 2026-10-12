import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';

void main() {
  const faculty = Faculty(id: 'id', name: 'name');
  late FacultyMutationBloc facultyMutationBlocMock;

  group('FacultyForm', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      facultyMutationBlocMock = getIt<FacultyMutationBloc>();
      whenListen(
        facultyMutationBlocMock,
        Stream.value(const FacultyMutationState()),
        initialState: const FacultyMutationState(),
      );
    });

    Future<void> pumpWidget(
      WidgetTester tester, {
      Faculty? initial,
      void Function(Faculty)? onFacultyDeleted,
    }) {
      return tester.pumpWidgetForTest(
        (context) => FacultyForm(
          initial: initial,
          onFacultyDeleted: onFacultyDeleted,
        ),
        providerBuilder: (context, child) {
          return BlocProvider.value(
            value: facultyMutationBlocMock,
            child: child,
          );
        },
      );
    }

    final nameFieldFinder = find.ancestor(
      of: find.text('Nama Fakultas *'),
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
      testWidgets('shows name field', (tester) async {
        await pumpWidget(tester);

        expect(
          nameFieldFinder,
          findsOneWidget,
        );
      });

      testWidgets(
        'shows save button',
        (tester) async {
          await pumpWidget(tester);

          expect(saveButtonFinder, findsOneWidget);
        },
      );

      testWidgets(
        'shows delete button when initial is provided',
        (tester) async {
          await pumpWidget(tester, initial: faculty);

          expect(deleteButtonFinder, findsOneWidget);
        },
      );

      testWidgets(
        'hide delete button when initial is null',
        (tester) async {
          await pumpWidget(tester);

          expect(deleteButtonFinder, findsNothing);
        },
      );

      testWidgets('shows initial faculty when provided', (tester) async {
        await pumpWidget(tester, initial: faculty);

        expect(find.text(faculty.name), findsOneWidget);
      });

      testWidgets(
        'shows LoadingIndicator and disable save button '
        'when FacultyMutationState isCreating true',
        (tester) async {
          whenListen(
            facultyMutationBlocMock,
            Stream.value(const FacultyMutationState(isCreating: true)),
          );

          await pumpWidget(tester);
          await tester.pump();

          expect(find.byType(LoadingIndicator), findsOneWidget);
          expect(tester.widget<AppButton>(saveButtonFinder).onPressed, isNull);
        },
      );

      testWidgets(
        'shows LoadingIndicator on save button and disable it '
        'when FacultyMutationState updatingIds contains initial faculty',
        (tester) async {
          whenListen(
            facultyMutationBlocMock,
            Stream.value(FacultyMutationState(updatingIds: {faculty.id})),
          );

          await pumpWidget(tester, initial: faculty);
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
        'when FacultyMutationState updateingIds contains initial faculty',
        (tester) async {
          whenListen(
            facultyMutationBlocMock,
            Stream.value(FacultyMutationState(deletingIds: {faculty.id})),
          );

          await pumpWidget(tester, initial: faculty);
          await tester.pump();

          expect(
            tester.widget<AppButton>(deleteButtonFinder).onPressed,
            isNull,
          );
        },
      );

      testWidgets(
        'disable save button '
        'when FacultyMutationState deletingIds contains initial faculty',
        (tester) async {
          whenListen(
            facultyMutationBlocMock,
            Stream.value(FacultyMutationState(deletingIds: {faculty.id})),
          );

          await pumpWidget(tester, initial: faculty);
          await tester.pump();

          expect(
            tester.widget<AppButton>(saveButtonFinder).onPressed,
            isNull,
          );
        },
      );

      testWidgets(
        'shows LoadingIndicator on delete button and disable it '
        'when FacultyMutationState deletingIds contains initial faculty',
        (tester) async {
          whenListen(
            facultyMutationBlocMock,
            Stream.value(FacultyMutationState(deletingIds: {faculty.id})),
          );

          await pumpWidget(tester, initial: faculty);
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
        'add FacultyMutationCreateRequested when initial is null '
        'and save valid fields',
        (tester) async {
          await pumpWidget(tester);

          await tester.enterText(nameFieldFinder, 'text');
          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          verify(
            () => facultyMutationBlocMock.add(
              const FacultyMutationCreateRequested(name: 'text'),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'add FacultyMutationUpdateRequested when initial is provided '
        'and save valid fields',
        (tester) async {
          await pumpWidget(tester, initial: faculty);

          await tester.enterText(nameFieldFinder, 'text');
          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          verify(
            () => facultyMutationBlocMock.add(
              const FacultyMutationUpdateRequested(
                faculty: faculty,
                name: 'text',
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'add FacultyMutationDeleteRequested when delete button pressed',
        (tester) async {
          await pumpWidget(tester, initial: faculty);

          await tester.tap(deleteButtonFinder);
          await tester.pumpAndSettle();
          // Confirm on dialog
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();

          verify(
            () => facultyMutationBlocMock.add(
              const FacultyMutationDeleteRequested(
                faculty: faculty,
              ),
            ),
          ).called(1);
        },
      );
    });

    group('Side Effects', () {
      testWidgets('clear all fields when create success', (tester) async {
        final controller = StreamController<FacultyMutationState>.broadcast();
        when(() => facultyMutationBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester);

        await tester.enterText(nameFieldFinder, 'text');
        expect(find.text('text'), findsOneWidget);

        controller.add(
          const FacultyMutationState(notice: FacultyCreatedNotice(faculty)),
        );
        await tester.pumpAndSettle();

        expect(find.text('text'), findsNothing);
      });

      testWidgets('not clear all fields when update success', (tester) async {
        final controller = StreamController<FacultyMutationState>.broadcast();
        when(() => facultyMutationBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester);

        await tester.enterText(nameFieldFinder, 'text');
        expect(find.text('text'), findsOneWidget);

        controller.add(
          const FacultyMutationState(
            notice: FacultyUpdatedNotice(before: faculty, after: faculty),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('text'), findsOneWidget);
      });

      testWidgets('shows success dialog with correct title and message '
          'when create success', (tester) async {
        final controller = StreamController<FacultyMutationState>.broadcast();
        when(() => facultyMutationBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester);
        controller.add(
          const FacultyMutationState(
            notice: FacultyCreatedNotice(faculty),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Fakultas berhasil disimpan'), findsOneWidget);
        expect(
          find.text('Fakulas dengan nama "${faculty.name}" berhasil disimpan'),
          findsOneWidget,
        );
      });

      testWidgets('shows success dialog with correct title and message '
          'when update success', (tester) async {
        const updated = Faculty(id: 'id', name: 'updated');
        final controller = StreamController<FacultyMutationState>.broadcast();
        when(() => facultyMutationBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester);
        controller.add(
          const FacultyMutationState(
            notice: FacultyUpdatedNotice(before: faculty, after: updated),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Fakultas "${faculty.name}" berhasil diperbarui'),
          findsOneWidget,
        );
        expect(
          find.text(
            'Fakulas "${faculty.name}" berhasil diperbarui '
            'dengan nama "${updated.name}"',
          ),
          findsOneWidget,
        );
      });

      testWidgets('shows success dialog with correct title and message '
          'when delete success', (tester) async {
        final controller = StreamController<FacultyMutationState>.broadcast();
        when(() => facultyMutationBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester);
        controller.add(
          const FacultyMutationState(
            notice: FacultyDeletedNotice(faculty),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Fakultas berhasil dihapus'),
          findsOneWidget,
        );
        expect(
          find.text(
            'Fakulas dengan nama "${faculty.name}" berhasil dihapus',
          ),
          findsOneWidget,
        );
      });

      testWidgets('shows failed dialog with correct title and message '
          'when create failed', (tester) async {
        final controller = StreamController<FacultyMutationState>.broadcast();
        when(() => facultyMutationBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester);
        controller.add(
          FacultyMutationState(
            notice: FacultyMutationFailedNotice(
              type: .create,
              exception: AppException.test(),
              faculty: null,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Gagal menyimpan fakultas baru'),
          findsOneWidget,
        );
        expect(
          find.text('Terjadi kesalahan internal. Harap coba lagi nanti'),
          findsOneWidget,
        );
      });

      testWidgets('shows failed dialog with correct title and message '
          'when update failed', (tester) async {
        final controller = StreamController<FacultyMutationState>.broadcast();
        when(() => facultyMutationBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester);
        controller.add(
          FacultyMutationState(
            notice: FacultyMutationFailedNotice(
              type: .update,
              exception: AppException.test(),
              faculty: faculty,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Gagal memperbarui fakultas'),
          findsOneWidget,
        );
        expect(
          find.text('Terjadi kesalahan internal. Harap coba lagi nanti'),
          findsOneWidget,
        );
      });

      testWidgets('shows failed dialog with correct title and message '
          'when delete failed', (tester) async {
        final controller = StreamController<FacultyMutationState>.broadcast();
        when(() => facultyMutationBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester);
        controller.add(
          FacultyMutationState(
            notice: FacultyMutationFailedNotice(
              type: .delete,
              exception: AppException.test(),
              faculty: faculty,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Gagal menghapus fakultas'),
          findsOneWidget,
        );
        expect(
          find.text('Terjadi kesalahan internal. Harap coba lagi nanti'),
          findsOneWidget,
        );
      });

      testWidgets('calls onFacultyDeleted after dialog close '
          'when delete success', (tester) async {
        final controller = StreamController<FacultyMutationState>.broadcast();
        when(() => facultyMutationBlocMock.stream)
            .thenAnswer((_) => controller.stream);
        Faculty? deleted;

        await pumpWidget(
          tester,
          onFacultyDeleted: (v) {
            deleted = v;
          },
        );
        controller.add(
          const FacultyMutationState(
            notice: FacultyDeletedNotice(faculty),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(AppButton),
          ),
        );
        await tester.pumpAndSettle();

        expect(deleted, faculty);
      });
    });
  });
}
