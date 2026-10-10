import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';

void main() {
  const faculty = Faculty(id: 'id', name: 'name');
  late FacultyMutationBloc facultyMutationBlocMock;

  group('FacultyForm', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      facultyMutationBlocMock = getItMock<FacultyMutationBloc>();
      whenListen(
        facultyMutationBlocMock,
        Stream.value(const FacultyMutationState()),
        initialState: const FacultyMutationState(),
      );
    });

    Future<void> pumpWidget(
      WidgetTester tester, {
      Faculty? initial,
    }) {
      return tester.pumpWidgetForTest(
        (context) => FacultyForm(
          initial: initial,
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
    final saveButtonFinder = find.byType(AppButton);

    group('Render', () {
      testWidgets('shows name field', (tester) async {
        await pumpWidget(tester);

        expect(
          nameFieldFinder,
          findsOneWidget,
        );
      });

      testWidgets(
        'shows correct save button '
        'when initial is not provided',
        (tester) async {
          await pumpWidget(tester);

          expect(
            find.ancestor(
              of: find.text('Simpan'),
              matching: find.byType(AppButton),
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows correct save button '
        'when initial is provided',
        (tester) async {
          await pumpWidget(tester, initial: faculty);

          expect(
            find.ancestor(
              of: find.text('Perbarui'),
              matching: find.byType(AppButton),
            ),
            findsOneWidget,
          );
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
        'shows LoadingIndicator and disable save button '
        'when FacultyMutationState updatingIds contains initial faculty',
        (tester) async {
          whenListen(
            facultyMutationBlocMock,
            Stream.value(FacultyMutationState(updatingIds: {faculty.id})),
          );

          await pumpWidget(tester, initial: faculty);
          await tester.pump();

          expect(find.byType(LoadingIndicator), findsOneWidget);
          expect(tester.widget<AppButton>(saveButtonFinder).onPressed, isNull);
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

      testWidgets('clear all fields when update success', (tester) async {
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

        expect(find.text('text'), findsNothing);
      });
    });
  });
}
