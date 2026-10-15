import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late FacultySelectorController controller;
  late FacultiesBloc facultiesBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    facultiesBlocMock = getIt<FacultiesBloc>();
    whenListen(
      facultiesBlocMock,
      Stream.value(FacultiesLoaded(facultiesMock)),
      initialState: FacultiesLoaded(facultiesMock),
    );

    controller = FacultySelectorController();
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    String? label,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return FacultySelector(
          label: label ?? 'Label',
          controller: controller,
        );
      },
      providerBuilder: (context, child) {
        return BlocProvider.value(
          value: facultiesBlocMock,
          child: child,
        );
      },
    );
  }

  Future<void> openSelector(
    WidgetTester tester, {
    bool pumpOnly = false,
  }) async {
    await tester.tap(find.byType(AppFormField));
    if (pumpOnly) {
      await tester.pump();
    } else {
      await tester.pumpAndSettle();
    }
  }

  group('FacultySelector', () {
    group('Render', () {
      testWidgets('shows selected faculty on field', (tester) async {
        await pumpWidget(tester);

        controller.selected = facultiesMock.first;
        await tester.pumpAndSettle();

        expect(find.text(facultiesMock.first.name), findsOneWidget);
      });

      testWidgets(
        'shows LoadingIndicator on dialog when state is loading',
        (tester) async {
          whenListen(
            facultiesBlocMock,
            Stream.value(const LoadingFaculties()),
            initialState: const LoadingFaculties(),
          );
          await pumpWidget(tester);

          await openSelector(tester, pumpOnly: true);

          expect(find.byType(LoadingIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'shows AppExceptionBox on dialog when state is failed',
        (tester) async {
          whenListen(
            facultiesBlocMock,
            Stream.value(FacultiesFailure(AppException.test())),
            initialState: FacultiesFailure(AppException.test()),
          );
          await pumpWidget(tester);

          await openSelector(tester);

          final finder = find.byType(AppExceptionBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppExceptionBox>(finder);
          expect(widget.exception, AppException.test());
        },
      );

      testWidgets(
        'shows correct list of faculties on dialog when state is loaded',
        (tester) async {
          await pumpWidget(tester);

          await openSelector(tester);

          for (final f in facultiesMock) {
            final finder = find.ancestor(
              of: find.text(f.name),
              matching: find.byType(CheckboxListTile),
            );
            await tester.ensureVisible(finder);
            expect(finder, findsOneWidget);
          }
        },
      );

      testWidgets(
        'shows selected faculty on dialog when state is loaded',
        (tester) async {
          await pumpWidget(tester);
          controller.selected = facultiesMock.first;

          await openSelector(tester);

          for (final f in facultiesMock) {
            final finder = find.ancestor(
              of: find.text(f.name),
              matching: find.byType(CheckboxListTile),
            );
            await tester.ensureVisible(finder);
            expect(finder, findsOneWidget);
            final widget = tester.widget<CheckboxListTile>(finder);
            expect(widget.selected, f == facultiesMock.first);
            expect(widget.value, f == facultiesMock.first);
          }
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'open selector dialog when field is pressed',
        (tester) async {
          await pumpWidget(tester);

          await openSelector(tester);

          expect(find.text('Pilih Fakultas'), findsOneWidget);
        },
      );

      testWidgets(
        'can select a faculty',
        (tester) async {
          await pumpWidget(tester);
          final first = facultiesMock.first;

          expect(find.text(first.name), findsNothing);
          await openSelector(tester);
          final firstFinder = find.ancestor(
            of: find.text(first.name),
            matching: find.byType(CheckboxListTile),
          );
          await tester.ensureVisible(firstFinder);
          await tester.tap(firstFinder);
          await tester.pumpAndSettle();

          expect(find.text(first.name), findsOneWidget);
          expect(controller.selected, first);
        },
      );
    });
  });
}
