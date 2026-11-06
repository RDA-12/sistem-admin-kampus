import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late AcademicYearSelectorController controller;
  late AcademicYearsBloc academicYearsBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    academicYearsBlocMock = getIt<AcademicYearsBloc>();
    whenListen(
      academicYearsBlocMock,
      Stream.value(AcademicYearsLoaded(academicYearsMock)),
      initialState: AcademicYearsLoaded(academicYearsMock),
    );

    controller = AcademicYearSelectorController();
  });

  tearDown(() {
    reset(academicYearsBlocMock);
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    String? label,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return AcademicYearSelector(
          label: label ?? 'Label',
          controller: controller,
        );
      },
      providerBuilder: (context, child) {
        return BlocProvider.value(
          value: academicYearsBlocMock,
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

  group('AcademicYearSelectorController', () {
    test('sets itemAsString to (it) => it.name on initial', () {
      final ctrl = AcademicYearSelectorController(
        initial: academicYearsMock.first,
      );

      expect(ctrl.selected, academicYearsMock.first);
      expect(ctrl.textEditingController.text, academicYearsMock.first.name);
    });

    test('sets itemAsString to (it) => it.name when selected is changed', () {
      controller.selected = academicYearsMock.first;

      expect(
        controller.textEditingController.text,
        academicYearsMock.first.name,
      );
    });
  });

  group('AcademicYearSelector', () {
    group('Render', () {
      testWidgets('configures AppSelector correctly', (tester) async {
        await pumpWidget(tester, label: 'Custom Academic Year');

        final appSelectorFinder = find.byType(AppSelector<AcademicYear>);
        expect(appSelectorFinder, findsOneWidget);

        final appSelector = tester.widget<AppSelector<AcademicYear>>(
          appSelectorFinder,
        );
        expect(appSelector.label, 'Custom Academic Year');
        expect(appSelector.dialogTitle, 'Pilih Tahun Ajaran');
        expect(appSelector.controller, controller);
      });

      testWidgets(
        'shows LoadingIndicator on dialog when state is loading',
        (tester) async {
          whenListen(
            academicYearsBlocMock,
            Stream.value(const LoadingAcademicYears()),
            initialState: const LoadingAcademicYears(),
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
            academicYearsBlocMock,
            Stream.value(AcademicYearsFailure(AppException.test())),
            initialState: AcademicYearsFailure(AppException.test()),
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
        'ensures options showed to users is the name of AcademicYear',
        (tester) async {
          await pumpWidget(tester);

          await openSelector(tester);

          for (final y in academicYearsMock) {
            final finder = find.ancestor(
              of: find.text(y.name),
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
        'triggers AcademicYearsSubscriptionRequested when selector is pressed',
        (tester) async {
          await pumpWidget(tester);

          await openSelector(tester);

          verify(
            () => academicYearsBlocMock.add(
              const AcademicYearsSubscriptionRequested(),
            ),
          ).called(1);
        },
      );
    });
  });
}
