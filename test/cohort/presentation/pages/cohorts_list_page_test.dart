import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late CohortsBloc cohortsBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    cohortsBlocMock = getIt<CohortsBloc>();
    whenListen(
      cohortsBlocMock,
      Stream.value(CohortsLoaded(cohortsMock)),
      initialState: CohortsLoaded(cohortsMock),
    );
    when(cohortsBlocMock.close).thenAnswer((_) async {});

    whenListen(
      getIt<CohortMutationBloc>(),
      Stream.value(const CohortMutationState()),
      initialState: const CohortMutationState(),
    );
    when(getIt<CohortMutationBloc>().close).thenAnswer((_) async {});

    whenListen(
      getIt<CohortDetailBloc>(),
      Stream.value(const CohortDetailLoaded(cohort: cohortMock)),
      initialState: const CohortDetailLoaded(cohort: cohortMock),
    );
    when(getIt<CohortDetailBloc>().close).thenAnswer((_) async {});
  });

  tearDown(() {
    reset(cohortsBlocMock);
    reset(getIt<CohortMutationBloc>());
    reset(getIt<CohortDetailBloc>());
  });

  Future<void> pumpWidget(WidgetTester tester, {Size? phoneSize}) {
    return tester.pumpPageForTest(
      path: '/cohorts',
      page: const CohortsListPage(),
      phoneSize: phoneSize,
      childRoutes: [
        GoRoute(
          path: 'create',
          builder: (_, _) {
            return const CreateCohortPage();
          },
        ),
        GoRoute(
          path: 'create-compact',
          builder: (_, _) {
            return const CreateCohortPage();
          },
        ),
        GoRoute(
          path: ':id',
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            return CohortDetailPage(id: id);
          },
        ),
        GoRoute(
          path: 'compact/:id',
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            return CohortDetailPage(id: id);
          },
        ),
      ],
    );
  }

  group('CohortsListPage', () {
    Future<void> createButtonPressed(WidgetTester tester) async {
      final widget = tester.widget<CohortsList>(
        find.byType(CohortsList),
      );
      widget.onCreatePressed!();
      await tester.pumpAndSettle();
    }

    Future<void> cohortPressed(WidgetTester tester) async {
      final widget = tester.widget<CohortsList>(
        find.byType(CohortsList),
      );
      widget.onPressed!(cohortMock);
      await tester.pumpAndSettle();
    }

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Daftar Angkatan'), findsOneWidget);
      });

      testWidgets('provides CohortsBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<CohortsBloc>), findsOneWidget);
      });

      testWidgets('shows CohortsList in compact screen', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(450, 800));

        expect(find.byType(CohortsList), findsOneWidget);
      });

      testWidgets('shows CohortsList in medium screen', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(650, 800));

        expect(find.byType(CohortsList), findsOneWidget);
      });

      testWidgets(
        'shows CohortsList and CreateCohortPage '
        'in expanded screen when create button is pressed',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(850, 800));

          await createButtonPressed(tester);

          expect(find.byType(CohortsList), findsOneWidget);
          expect(find.byType(CreateCohortPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows CohortsList and CreateCohortPage '
        'in large screen when create button is pressed',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await createButtonPressed(tester);

          expect(find.byType(CohortsList), findsOneWidget);
          expect(find.byType(CreateCohortPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows CohortsList and CohortDetailPage '
        'in expanded screen when a cohort is pressed',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(850, 800));

          await cohortPressed(tester);

          expect(find.byType(CohortsList), findsOneWidget);
          expect(find.byType(CohortDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows CohortsList and CohortDetailPage '
        'in large screen when a cohort is pressed',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await cohortPressed(tester);

          expect(find.byType(CohortsList), findsOneWidget);
          expect(find.byType(CohortDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'set selectedId on CohortsList '
        'when a cohort is pressed in expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(850, 800));

          await cohortPressed(tester);

          final widget = tester.widget<CohortsList>(
            find.byType(CohortsList),
          );
          expect(widget.selectedId, cohortMock.id);
        },
      );

      testWidgets(
        'set selectedId on CohortsList '
        'when a cohort is pressed in large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await cohortPressed(tester);

          final widget = tester.widget<CohortsList>(
            find.byType(CohortsList),
          );
          expect(widget.selectedId, cohortMock.id);
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'go to create page when create button is pressed in compact screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(450, 800));

          await createButtonPressed(tester);

          expect(find.byType(CohortsList), findsNothing);
          expect(find.byType(CreateCohortPage), findsOneWidget);
        },
      );

      testWidgets(
        'go to create page when create button is pressed in medium screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(650, 800));

          await createButtonPressed(tester);

          expect(find.byType(CohortsList), findsNothing);
          expect(find.byType(CreateCohortPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows create page when create button is pressed in expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(900, 800));

          await createButtonPressed(tester);

          expect(find.byType(CohortsList), findsOneWidget);
          expect(find.byType(CreateCohortPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows create page when create button is pressed in large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await createButtonPressed(tester);

          expect(find.byType(CohortsList), findsOneWidget);
          expect(find.byType(CreateCohortPage), findsOneWidget);
        },
      );

      testWidgets(
        'go to detail page when a cohort is pressed in compact screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(450, 800));

          await cohortPressed(tester);

          expect(find.byType(CohortsList), findsNothing);
          expect(find.byType(CohortDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'go to detail page when a cohort is pressed in medium screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(650, 800));

          await cohortPressed(tester);

          expect(find.byType(CohortsList), findsNothing);
          expect(find.byType(CohortDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows detail page when a cohort is pressed in expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(900, 800));

          await cohortPressed(tester);

          expect(find.byType(CohortsList), findsOneWidget);
          expect(find.byType(CohortDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows detail page when a cohort is pressed in large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await cohortPressed(tester);

          expect(find.byType(CohortsList), findsOneWidget);
          expect(find.byType(CohortDetailPage), findsOneWidget);
        },
      );
    });

    group('Side Effects', () {
      testWidgets(
        'hides CohortDetail page when it fires onCohortDeleted '
        'in expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(850, 800));

          await cohortPressed(tester);

          final cohortDetailPageFinder = find.byType(CohortDetailPage);
          expect(cohortDetailPageFinder, findsOneWidget);

          final widget = tester.widget<CohortDetailPage>(
            cohortDetailPageFinder,
          );
          widget.onCohortDeleted!(cohortMock);
          await tester.pumpAndSettle();

          expect(cohortDetailPageFinder, findsNothing);
        },
      );

      testWidgets(
        'hides CohortDetail page when it fires onCohortDeleted '
        'in large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await cohortPressed(tester);

          final cohortDetailPageFinder = find.byType(CohortDetailPage);
          expect(cohortDetailPageFinder, findsOneWidget);

          final widget = tester.widget<CohortDetailPage>(
            cohortDetailPageFinder,
          );
          widget.onCohortDeleted!(cohortMock);
          await tester.pumpAndSettle();

          expect(cohortDetailPageFinder, findsNothing);
        },
      );
    });
  });
}
