import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late CohortDetailBloc cohortDetailBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    cohortDetailBlocMock = getIt<CohortDetailBloc>();
    whenListen(
      cohortDetailBlocMock,
      Stream.value(const CohortDetailLoaded(cohort: cohortMock)),
      initialState: const CohortDetailLoaded(cohort: cohortMock),
    );
    when(cohortDetailBlocMock.close).thenAnswer((_) async {});

    whenListen(
      getIt<CohortMutationBloc>(),
      Stream.value(const CohortMutationState()),
      initialState: const CohortMutationState(),
    );
    when(getIt<CohortMutationBloc>().close).thenAnswer((_) async {});
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function(Cohort)? onCohortDeleted,
  }) {
    return tester.pumpPageForTest(
      page: CohortDetailPage(
        id: cohortMock.id,
        onCohortDeleted: onCohortDeleted,
      ),
    );
  }

  tearDown(() {
    reset(cohortDetailBlocMock);
  });

  group('CohortDetailPage', () {
    group('Init', () {
      testWidgets(
        'add CohortDetailSubscriptionRequested event to CohortDetailBloc',
        (tester) async {
          await pumpWidget(tester);

          verify(
            () => cohortDetailBlocMock.add(
              CohortDetailSubscriptionRequested(id: cohortMock.id),
            ),
          ).called(1);
        },
      );
    });

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Detail Angkatan'), findsOneWidget);
      });

      testWidgets('provides CohortDetailBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<CohortDetailBloc>), findsOneWidget);
      });

      testWidgets('provides CohortMutationBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<CohortMutationBloc>), findsOneWidget);
      });

      testWidgets('shows CohortDetail', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(CohortDetail), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets(
        'add CohortDetailSubscriptionRequested event '
        'when retry button on CohortDetail is pressed',
        (tester) async {
          await pumpWidget(tester);

          final cohortDetailFinder = find.byType(CohortDetail);
          expect(cohortDetailFinder, findsOneWidget);
          final widget = tester.widget<CohortDetail>(cohortDetailFinder);
          widget.onRetryPressed!();

          verify(
            () => cohortDetailBlocMock.add(
              CohortDetailSubscriptionRequested(id: cohortMock.id),
            ),
          ).called(2); // Expect called 2, one on init
        },
      );
    });

    group('Side Effects', () {
      testWidgets(
        'calls onCohortDeleted when CohortDetail fires onCohortDeleted',
        (tester) async {
          Cohort? cohort;

          await pumpWidget(
            tester,
            onCohortDeleted: (v) {
              cohort = v;
            },
          );

          final widget = tester.widget<CohortDetail>(
            find.byType(CohortDetail),
          );
          widget.onCohortDeleted!(cohortMock);

          expect(cohort, cohortMock);
        },
      );
    });
  });
}
