import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';
import '../../domain/mocks.dart';

void main() {
  final year = academicYearMock;
  final terms = academicTermsMock;
  late WatchSingleAcademicYearUseCase watchSingleAcademicYearMock;
  late WatchAcademicTermsUseCase watchAcademicTermsMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    watchSingleAcademicYearMock = getIt<WatchSingleAcademicYearUseCase>();
    watchAcademicTermsMock = getIt<WatchAcademicTermsUseCase>();

    when(() => watchSingleAcademicYearMock(year.id))
        .thenAnswer((_) => Stream.value(AppResult.success(year)));
    when(
      () => watchAcademicTermsMock(
        AcademicTermFilter(academicYearId: year.id),
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success(terms)));
  });

  tearDown(() {
    reset(watchSingleAcademicYearMock);
    reset(watchAcademicTermsMock);
  });

  AcademicYearDetailBloc buildBloc() {
    return AcademicYearDetailBloc(
      watchSingleAcademicYear: watchSingleAcademicYearMock,
      watchAcademicTerms: watchAcademicTermsMock,
    );
  }

  group('AcademicYearDetailBloc', () {
    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const AcademicYearDetailInitial());
    });

    group('AcademicYearDetailSubscriptionRequested', () {
      blocTest<AcademicYearDetailBloc, AcademicYearDetailState>(
        'emits [LoadingAcademicYearDetail, AcademicYearDetailLoaded] '
        'when AcademicYearDetailSubscriptionRequested is added and '
        'use cases emit success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicYearDetailSubscriptionRequested(id: year.id),
        ),
        expect: () => <AcademicYearDetailState>[
          const LoadingAcademicYearDetail(),
          AcademicYearDetailLoaded(
            academicYear: year,
            terms: terms,
          ),
        ],
        verify: (_) {
          verify(() => watchSingleAcademicYearMock(year.id)).called(1);
          verify(
            () => watchAcademicTermsMock(
              AcademicTermFilter(academicYearId: year.id),
            ),
          ).called(1);
        },
      );

      blocTest<AcademicYearDetailBloc, AcademicYearDetailState>(
        'emits [LoadingAcademicYearDetail, AcademicYearDetailLoadFailed] '
        'when WatchSingleAcademicYearUseCase emits failure',
        setUp: () {
          when(() => watchSingleAcademicYearMock(year.id)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicYearDetailSubscriptionRequested(id: year.id),
        ),
        expect: () => <AcademicYearDetailState>[
          const LoadingAcademicYearDetail(),
          AcademicYearDetailLoadFailed(exception: AppException.test()),
        ],
      );

      blocTest<AcademicYearDetailBloc, AcademicYearDetailState>(
        'emits [LoadingAcademicYearDetail, AcademicYearDetailLoadFailed] '
        'when WatchAcademicTermsUseCase emits failure',
        setUp: () {
          when(
            () => watchAcademicTermsMock(
              AcademicTermFilter(academicYearId: year.id),
            ),
          ).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicYearDetailSubscriptionRequested(id: year.id),
        ),
        expect: () => <AcademicYearDetailState>[
          const LoadingAcademicYearDetail(),
          AcademicYearDetailLoadFailed(exception: AppException.test()),
        ],
      );
    });
  });
}
