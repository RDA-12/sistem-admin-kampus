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
  late CohortSelectorController controller;
  late CohortsBloc cohortsBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    cohortsBlocMock = getIt<CohortsBloc>();
    whenListen(
      cohortsBlocMock,
      Stream.value(CohortsLoaded(cohortsMock)),
      initialState: CohortsLoaded(cohortsMock),
    );

    controller = CohortSelectorController();
  });

  tearDown(() {
    reset(cohortsBlocMock);
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    String? label,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return CohortSelector(
          label: label ?? 'Label',
          controller: controller,
        );
      },
      providerBuilder: (context, child) {
        return BlocProvider.value(
          value: cohortsBlocMock,
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

  group('CohortSelectorController', () {
    test('sets itemAsString to (it) => it.name on initial', () {
      final ctrl = CohortSelectorController(initial: cohortsMock.first);

      expect(ctrl.selected, cohortsMock.first);
      expect(ctrl.textEditingController.text, cohortsMock.first.name);
    });

    test('sets itemAsString to (it) => it.name when selected is changed', () {
      controller.selected = cohortsMock.first;

      expect(controller.textEditingController.text, cohortsMock.first.name);
    });
  });

  group('CohortSelector', () {
    group('Render', () {
      testWidgets('configures AppSelector correctly', (tester) async {
        await pumpWidget(tester, label: 'Custom Cohort');

        final appSelectorFinder = find.byType(AppSelector<Cohort>);
        expect(appSelectorFinder, findsOneWidget);

        final appSelector = tester.widget<AppSelector<Cohort>>(
          appSelectorFinder,
        );
        expect(appSelector.label, 'Custom Cohort');
        expect(appSelector.dialogTitle, 'Pilih Angkatan');
        expect(appSelector.controller, controller);
      });

      testWidgets(
        'shows LoadingIndicator on dialog when state is loading',
        (tester) async {
          whenListen(
            cohortsBlocMock,
            Stream.value(const LoadingCohorts()),
            initialState: const LoadingCohorts(),
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
            cohortsBlocMock,
            Stream.value(CohortsFailure(AppException.test())),
            initialState: CohortsFailure(AppException.test()),
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
        'ensures options showed to users is the name of Cohort',
        (tester) async {
          await pumpWidget(tester);

          await openSelector(tester);

          for (final c in cohortsMock) {
            final finder = find.ancestor(
              of: find.text(c.name),
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
        'triggers CohortsSubscriptionRequested when selector is pressed',
        (tester) async {
          await pumpWidget(tester);

          await openSelector(tester);

          verify(
            () => cohortsBlocMock.add(const CohortsSubscriptionRequested()),
          ).called(1);
        },
      );
    });
  });
}
