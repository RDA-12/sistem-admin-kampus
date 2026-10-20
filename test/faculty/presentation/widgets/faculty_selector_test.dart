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

  tearDown(() {
    reset(facultiesBlocMock);
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

  group('FacultySelectorController', () {
    test('sets itemAsString to (it) => it.name on initial', () {
      final ctrl = FacultySelectorController(initial: facultiesMock.first);

      expect(ctrl.selected, facultiesMock.first);
      expect(ctrl.textEditingController.text, facultiesMock.first.name);
    });

    test('sets itemAsString to (it) => it.name when selected is changed', () {
      controller.selected = facultiesMock.first;

      expect(controller.textEditingController.text, facultiesMock.first.name);
    });
  });

  group('FacultySelector', () {
    group('Render', () {
      testWidgets('configures AppSelector correctly', (tester) async {
        await pumpWidget(tester, label: 'Custom Faculty');

        final appSelectorFinder = find.byType(AppSelector<Faculty>);
        expect(appSelectorFinder, findsOneWidget);

        final appSelector = tester.widget<AppSelector<Faculty>>(
          appSelectorFinder,
        );
        expect(appSelector.label, 'Custom Faculty');
        expect(appSelector.dialogTitle, 'Pilih Fakultas');
        expect(appSelector.controller, controller);
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
        'ensures options showed to users is the name of Faculty',
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
    });

    group('Interactions', () {
      testWidgets(
        'triggers FacultiesSubscriptionRequested when selector is pressed',
        (tester) async {
          await pumpWidget(tester);

          await openSelector(tester);

          verify(
            () => facultiesBlocMock.add(const FacultiesSubscriptionRequested()),
          ).called(1);
        },
      );
    });
  });
}
