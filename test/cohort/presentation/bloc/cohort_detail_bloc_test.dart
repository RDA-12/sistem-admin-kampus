import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';
import '../../domain/mocks.dart';

void main() {
  late WatchSingleCohortUseCase watchSingleCohortMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    watchSingleCohortMock = getIt<WatchSingleCohortUseCase>();

    when(() => watchSingleCohortMock(cohortMock.id))
        .thenAnswer((_) => Stream.value(AppResult.success(cohortMock)));
  });

  tearDown(() {
    reset(watchSingleCohortMock);
  });

  CohortDetailBloc buildBloc() {
    return CohortDetailBloc(
      watchSingleCohort: watchSingleCohortMock,
    );
  }

  group('CohortDetailBloc', () {
    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const CohortDetailInitial());
    });

    group('CohortDetailSubscriptionRequested', () {
      blocTest<CohortDetailBloc, CohortDetailState>(
        'emits [LoadingCohortDetail, CohortDetailLoaded] '
        'when CohortDetailSubscriptionRequested is added and '
        'WatchSingleCohortUseCase emits success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          CohortDetailSubscriptionRequested(id: cohortMock.id),
        ),
        expect: () => const <CohortDetailState>[
          LoadingCohortDetail(),
          CohortDetailLoaded(cohort: cohortMock),
        ],
        verify: (_) {
          verify(() => watchSingleCohortMock(cohortMock.id)).called(1);
        },
      );

      blocTest<CohortDetailBloc, CohortDetailState>(
        'emits [LoadingCohortDetail, CohortDetailLoadFailed] '
        'when WatchSingleCohortUseCase emits failure',
        setUp: () {
          when(() => watchSingleCohortMock(cohortMock.id)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          CohortDetailSubscriptionRequested(id: cohortMock.id),
        ),
        expect: () => <CohortDetailState>[
          const LoadingCohortDetail(),
          CohortDetailLoadFailed(exception: AppException.test()),
        ],
        verify: (_) {
          verify(() => watchSingleCohortMock(cohortMock.id)).called(1);
        },
      );
    });
  });
}
