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
  late AcademicTermSelectorController controller;
  late AcademicTermsBloc academicTermsBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    academicTermsBlocMock = getIt<AcademicTermsBloc>();
    whenListen(
      academicTermsBlocMock,
      Stream.value(AcademicTermsLoaded(academicTermsMock)),
      initialState: AcademicTermsLoaded(academicTermsMock),
    );

    controller = AcademicTermSelectorController();
  });

  tearDown(() {
    reset(academicTermsBlocMock);
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    String? label,
    String? academicYearId,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return AcademicTermSelector(
          label: label ?? 'Label',
          controller: controller,
          academicYearId: academicYearId,
        );
      },
      providerBuilder: (context, child) {
        return BlocProvider.value(
          value: academicTermsBlocMock,
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

  group('AcademicTermSelectorController', () {
    test('sets itemAsString to (it) => it.name on initial', () {
      final ctrl = AcademicTermSelectorController(
        initial: academicTermsMock.first,
      );

      expect(ctrl.selected, academicTermsMock.first);
      expect(ctrl.textEditingController.text, academicTermsMock.first.name);
    });

    test('sets itemAsString to (it) => it.name when selected is changed', () {
      controller.selected = academicTermsMock.first;

      expect(
        controller.textEditingController.text,
        academicTermsMock.first.name,
      );
    });
  });

  group('AcademicTermSelector', () {
    group('Render', () {
      testWidgets('configures AppSelector correctly', (tester) async {
        await pumpWidget(tester, label: 'Custom Academic Term');

        final appSelectorFinder = find.byType(AppSelector<AcademicTerm>);
        expect(appSelectorFinder, findsOneWidget);

        final appSelector = tester.widget<AppSelector<AcademicTerm>>(
          appSelectorFinder,
        );
        expect(appSelector.label, 'Custom Academic Term');
        expect(appSelector.dialogTitle, 'Pilih Semester');
        expect(appSelector.controller, controller);
      });

      testWidgets(
        'shows LoadingIndicator on dialog when state is loading',
        (tester) async {
          whenListen(
            academicTermsBlocMock,
            Stream.value(const LoadingAcademicTerms()),
            initialState: const LoadingAcademicTerms(),
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
            academicTermsBlocMock,
            Stream.value(AcademicTermsFailure(AppException.test())),
            initialState: AcademicTermsFailure(AppException.test()),
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
        'ensures options showed to users is the name of AcademicTerm',
        (tester) async {
          await pumpWidget(tester);

          await openSelector(tester);

          for (final t in academicTermsMock) {
            final finder = find.ancestor(
              of: find.text(t.name),
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
        'triggers AcademicTermsSubscriptionRequested without academicYearId '
        'when selector is pressed',
        (tester) async {
          await pumpWidget(tester);

          await openSelector(tester);

          verify(
            () => academicTermsBlocMock.add(
              const AcademicTermsSubscriptionRequested(),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'triggers AcademicTermsSubscriptionRequested with academicYearId '
        'when selector is pressed and academicYearId is provided',
        (tester) async {
          await pumpWidget(tester, academicYearId: 'year-123');

          await openSelector(tester);

          verify(
            () => academicTermsBlocMock.add(
              const AcademicTermsSubscriptionRequested(
                academicYearId: 'year-123',
              ),
            ),
          ).called(1);
        },
      );
    });
  });
}
