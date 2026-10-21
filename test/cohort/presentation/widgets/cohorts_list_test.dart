import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late CohortsBloc cohortsBlocMock;

  group('CohortsList', () {
    final createButtonFinder = find.ancestor(
      of: find.text('Buat baru'),
      matching: find.byType(AppButton),
    );

    setUpAll(initializeMockDependencies);

    setUp(() {
      cohortsBlocMock = getIt<CohortsBloc>();
      whenListen(
        cohortsBlocMock,
        Stream.value(CohortsLoaded(cohortsMock)),
        initialState: CohortsLoaded(cohortsMock),
      );
    });

    Future<void> pumpWidget(
      WidgetTester tester, {
      void Function(Cohort)? onPressed,
      void Function()? onCreatePressed,
      String? selectedId,
    }) {
      return tester.pumpWidgetForTest(
        (context) {
          return CohortsList(
            selectedId: selectedId,
            onPressed: onPressed,
            onCreatePressed: onCreatePressed,
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

    tearDown(() {
      reset(cohortsBlocMock);
    });

    group('Render', () {
      testWidgets('shows all cohorts when state is loaded', (tester) async {
        await pumpWidget(tester);

        for (final cohort in cohortsMock) {
          final cohortFinder = find.ancestor(
            of: find.text(cohort.name),
            matching: find.byType(CohortListTile),
          );
          await tester.ensureVisible(cohortFinder);
          await tester.pumpAndSettle();
        }
      });

      testWidgets(
        'shows AppEmptyBox when state is loaded with empty data',
        (tester) async {
          whenListen(
            cohortsBlocMock,
            Stream.value(const CohortsLoaded([])),
            initialState: const CohortsLoaded([]),
          );

          await pumpWidget(tester);

          final finder = find.byType(AppEmptyBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppEmptyBox>(finder);
          expect(widget.message, 'Belum ada data angkatan');
        },
      );

      testWidgets('shows LoadingIndicator when state is loading/initial', (
        tester,
      ) async {
        final controller = StreamController<CohortsState>.broadcast();
        when(() => cohortsBlocMock.stream).thenAnswer((_) => controller.stream);

        await pumpWidget(tester);
        controller.add(const CohortsInitial());
        await tester.pump();

        expect(find.byType(LoadingIndicator), findsOneWidget);

        controller.add(const LoadingCohorts());
        await tester.pump();

        expect(find.byType(LoadingIndicator), findsOneWidget);
      });

      testWidgets(
        'shows AppExceptionBox when state is failure',
        (tester) async {
          whenListen(
            cohortsBlocMock,
            Stream.value(CohortsFailure(AppException.test())),
            initialState: CohortsFailure(AppException.test()),
          );

          await pumpWidget(tester);
          await tester.pumpAndSettle();

          final finder = find.byType(AppExceptionBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppExceptionBox>(finder);
          expect(widget.exception, AppException.test());
          expect(widget.title, 'Gagal mengambil data angkatan');
        },
      );

      testWidgets('shows create button', (tester) async {
        await pumpWidget(tester);

        expect(createButtonFinder, findsOneWidget);
      });

      testWidgets('shows selected CohortListTile', (tester) async {
        await pumpWidget(tester, selectedId: cohortsMock.first.id);

        for (final cohort in cohortsMock) {
          final finder = find.ancestor(
            of: find.text(cohort.name),
            matching: find.byType(CohortListTile),
          );
          await tester.ensureVisible(finder);
          final widget = tester.widget<CohortListTile>(finder);
          expect(widget.selected, cohort.id == cohortsMock.first.id);
        }
      });
    });

    group('Interactions', () {
      testWidgets(
        'calls onPressed with correct data '
        'when one of cohorts is pressed',
        (tester) async {
          Cohort? pressedCohort;
          await pumpWidget(
            tester,
            onPressed: (v) {
              pressedCohort = v;
            },
          );

          final cohortFinder = find.text(cohortsMock.first.name);
          await tester.ensureVisible(cohortFinder);
          await tester.pumpAndSettle();
          await tester.tap(cohortFinder);

          expect(pressedCohort, cohortsMock.first);
        },
      );

      testWidgets(
        'calls onCreatePressed when create button is pressed',
        (tester) async {
          var pressed = false;
          await pumpWidget(
            tester,
            onCreatePressed: () {
              pressed = true;
            },
          );

          await tester.tap(createButtonFinder);

          expect(pressed, isTrue);
        },
      );
    });
  });
}
