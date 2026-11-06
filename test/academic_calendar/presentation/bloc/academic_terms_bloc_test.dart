import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';
import '../../domain/mocks.dart';

void main() {
  group('AcademicTermsBloc', () {
    late WatchAcademicTermsUseCase watchAcademicTermsMock;

    setUpAll(initializeMockDependencies);

    setUp(() {
      watchAcademicTermsMock = getIt<WatchAcademicTermsUseCase>();
      when(() => watchAcademicTermsMock(any())).thenAnswer(
        (_) => Stream.value(AppResult.success(academicTermsMock)),
      );
    });

    tearDown(() {
      reset(watchAcademicTermsMock);
    });

    AcademicTermsBloc buildBloc() {
      return AcademicTermsBloc(
        watchAcademicTerms: watchAcademicTermsMock,
      );
    }

    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const AcademicTermsInitial());
    });

    group('AcademicTermsSubscriptionRequested', () {
      blocTest<AcademicTermsBloc, AcademicTermsState>(
        'emits [LoadingAcademicTerms, AcademicTermsLoaded] '
        'when AcademicTermsSubscriptionRequested is added '
        'and WatchAcademicTermsUseCase emits success',
        build: buildBloc,
        act: (bloc) => bloc.add(const AcademicTermsSubscriptionRequested()),
        expect: () => <AcademicTermsState>[
          const LoadingAcademicTerms(),
          AcademicTermsLoaded(academicTermsMock),
        ],
        verify: (_) {
          verify(
            () => watchAcademicTermsMock(const AcademicTermFilter()),
          ).called(1);
        },
      );

      blocTest<AcademicTermsBloc, AcademicTermsState>(
        'emits [LoadingAcademicTerms, AcademicTermsLoaded] '
        'when AcademicTermsSubscriptionRequested with academicYearId is added',
        build: buildBloc,
        act: (bloc) => bloc.add(
          const AcademicTermsSubscriptionRequested(academicYearId: 'mock-year'),
        ),
        expect: () => <AcademicTermsState>[
          const LoadingAcademicTerms(),
          AcademicTermsLoaded(academicTermsMock),
        ],
        verify: (_) {
          verify(
            () => watchAcademicTermsMock(
              const AcademicTermFilter(academicYearId: 'mock-year'),
            ),
          ).called(1);
        },
      );

      blocTest<AcademicTermsBloc, AcademicTermsState>(
        'emits [LoadingAcademicTerms, AcademicTermsFailure] '
        'when AcademicTermsSubscriptionRequested is added '
        'and WatchAcademicTermsUseCase emits failure',
        setUp: () {
          when(
            () => watchAcademicTermsMock(const AcademicTermFilter()),
          ).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const AcademicTermsSubscriptionRequested()),
        expect: () => <AcademicTermsState>[
          const LoadingAcademicTerms(),
          AcademicTermsFailure(AppException.test()),
        ],
      );
    });
  });
}
