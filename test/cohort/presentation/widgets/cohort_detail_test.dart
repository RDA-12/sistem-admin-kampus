import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

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
      Stream.value(
        const CohortDetailLoaded(
          cohort: cohortMock,
        ),
      ),
      initialState: const CohortDetailLoaded(
        cohort: cohortMock,
      ),
    );

    whenListen(
      getIt<CohortMutationBloc>(),
      Stream.value(const CohortMutationState()),
      initialState: const CohortMutationState(),
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function()? onRetryPressed,
    void Function(Cohort)? onCohortDeleted,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return CohortDetail(
          onRetryPressed: onRetryPressed,
          onCohortDeleted: onCohortDeleted,
        );
      },
      providerBuilder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: cohortDetailBlocMock,
            ),
            BlocProvider.value(
              value: getIt<CohortMutationBloc>(),
            ),
          ],
          child: child,
        );
      },
    );
  }

  group('CohortDetail', () {
    group('Render', () {
      testWidgets(
        'shows CohortForm with correct cohort '
        'when state is loaded',
        (tester) async {
          await pumpWidget(tester);

          final finder = find.byType(CohortForm);
          expect(finder, findsOneWidget);
          final widget = tester.widget<CohortForm>(finder);
          expect(widget.initial, cohortMock);
        },
      );

      testWidgets(
        'shows LoadingIndicator when state is loading',
        (tester) async {
          whenListen(
            cohortDetailBlocMock,
            Stream.value(const LoadingCohortDetail()),
            initialState: const LoadingCohortDetail(),
          );

          await pumpWidget(tester);

          expect(find.byType(LoadingIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'shows AppExceptionBox when state is failed',
        (tester) async {
          whenListen(
            cohortDetailBlocMock,
            Stream.value(
              CohortDetailLoadFailed(exception: AppException.test()),
            ),
            initialState: CohortDetailLoadFailed(
              exception: AppException.test(),
            ),
          );

          await pumpWidget(tester);

          final finder = find.byType(AppExceptionBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppExceptionBox>(finder);
          expect(widget.title, 'Gagal mengambil data angkatan');
          expect(widget.exception, AppException.test());
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'calls onRetryPressed when state is failed '
        'and retry button is pressed',
        (tester) async {
          whenListen(
            cohortDetailBlocMock,
            Stream.value(
              CohortDetailLoadFailed(exception: AppException.test()),
            ),
            initialState: CohortDetailLoadFailed(
              exception: AppException.test(),
            ),
          );
          var pressed = false;
          await pumpWidget(
            tester,
            onRetryPressed: () {
              pressed = true;
            },
          );

          await tester.tap(
            find.descendant(
              of: find.byType(AppExceptionBox),
              matching: find.byType(AppButton),
            ),
          );

          expect(pressed, isTrue);
        },
      );
    });

    group('Side Effects', () {
      testWidgets(
        'calls onCohortDeleted '
        'when CohortDetail fires onCohortDeleted callback',
        (tester) async {
          Cohort? deleted;

          await pumpWidget(
            tester,
            onCohortDeleted: (v) {
              deleted = v;
            },
          );

          final finder = find.byType(CohortForm);
          expect(finder, findsOneWidget);
          final widget = tester.widget<CohortForm>(finder);
          widget.onCohortDeleted!(cohortMock);

          expect(deleted, cohortMock);
        },
      );
    });
  });
}
