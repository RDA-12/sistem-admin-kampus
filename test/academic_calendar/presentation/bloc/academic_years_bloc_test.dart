import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';
import '../../domain/mocks.dart';

void main() {
  group('AcademicYearsBloc', () {
    late WatchAcademicYearsUseCase watchAcademicYearsMock;

    setUpAll(initializeMockDependencies);

    setUp(() {
      watchAcademicYearsMock = getIt<WatchAcademicYearsUseCase>();
      when(() => watchAcademicYearsMock(null)).thenAnswer(
        (_) => Stream.value(AppResult.success(academicYearsMock)),
      );
    });

    tearDown(() {
      reset(watchAcademicYearsMock);
    });

    AcademicYearsBloc buildBloc() {
      return AcademicYearsBloc(
        watchAcademicYears: watchAcademicYearsMock,
      );
    }

    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const AcademicYearsInitial());
    });

    group('AcademicYearsSubscriptionRequested', () {
      blocTest<AcademicYearsBloc, AcademicYearsState>(
        'emits [LoadingAcademicYears, AcademicYearsLoaded] '
        'when AcademicYearsSubscriptionRequested is added '
        'and WatchAcademicYearsUseCase emits success',
        build: buildBloc,
        act: (bloc) => bloc.add(const AcademicYearsSubscriptionRequested()),
        expect: () => <AcademicYearsState>[
          const LoadingAcademicYears(),
          AcademicYearsLoaded(academicYearsMock),
        ],
        verify: (_) {
          verify(() => watchAcademicYearsMock(null)).called(1);
        },
      );

      blocTest<AcademicYearsBloc, AcademicYearsState>(
        'emits [LoadingAcademicYears, AcademicYearsFailure] '
        'when AcademicYearsSubscriptionRequested is added '
        'and WatchAcademicYearsUseCase emits failure',
        setUp: () {
          when(() => watchAcademicYearsMock(null)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const AcademicYearsSubscriptionRequested()),
        expect: () => <AcademicYearsState>[
          const LoadingAcademicYears(),
          AcademicYearsFailure(AppException.test()),
        ],
      );
    });
  });
}
