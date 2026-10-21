import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';
import '../../domain/mocks.dart';

void main() {
  group('CohortsBloc', () {
    late WatchCohortsUseCase watchCohortsMock;

    setUpAll(initializeMockDependencies);

    setUp(() {
      watchCohortsMock = getIt<WatchCohortsUseCase>();
      when(() => watchCohortsMock(null)).thenAnswer(
        (_) => Stream.value(AppResult.success(cohortsMock)),
      );
    });

    tearDown(() {
      reset(watchCohortsMock);
    });

    CohortsBloc buildBloc() {
      return CohortsBloc(
        watchCohorts: watchCohortsMock,
      );
    }

    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const CohortsInitial());
    });

    group('CohortsSubscriptionRequested', () {
      blocTest<CohortsBloc, CohortsState>(
        'emits [LoadingCohorts, CohortsLoaded] '
        'when CohortsSubscriptionRequested is added '
        'and WatchCohortsUseCase emits success',
        build: buildBloc,
        act: (bloc) => bloc.add(const CohortsSubscriptionRequested()),
        expect: () => <CohortsState>[
          const LoadingCohorts(),
          CohortsLoaded(cohortsMock),
        ],
        verify: (_) {
          verify(() => watchCohortsMock(null)).called(1);
        },
      );

      blocTest<CohortsBloc, CohortsState>(
        'emits [LoadingCohorts, CohortsFailure] '
        'when CohortsSubscriptionRequested is added '
        'and WatchCohortsUseCase emits failure',
        setUp: () {
          when(() => watchCohortsMock(null)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const CohortsSubscriptionRequested()),
        expect: () => <CohortsState>[
          const LoadingCohorts(),
          CohortsFailure(AppException.test()),
        ],
      );
    });
  });
}
