import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../../common/di_mocks.dart';

void main() {
  final faculties = List.generate(
    5,
    (index) => Faculty(id: '$index', name: '$index'),
  );

  group('FacultiesBloc', () {
    late WatchFacultiesUseCase watchFacultiesMock;

    setUpAll(initializeMockDependencies);

    setUp(() {
      watchFacultiesMock = getItMock<WatchFacultiesUseCase>();
      when(() => watchFacultiesMock(null))
          .thenAnswer((_) => Stream.value(AppResult.success(faculties)));
    });

    FacultiesBloc buildBloc() {
      return FacultiesBloc(
        watchFaculties: watchFacultiesMock,
      );
    }

    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const FacultiesInitial());
    });

    group('SubscriptionRequested', () {
      blocTest<FacultiesBloc, FacultiesState>(
        'emits [LoadingFaculties, FacultiesLoaded] '
        'when SubscriptionRequested is added '
        'and WatchFacultiesUseCase emits success',
        build: buildBloc,
        act: (bloc) => bloc.add(const SubscriptionRequested()),
        expect: () => <FacultiesState>[
          const LoadingFaculties(),
          FacultiesLoaded(faculties),
        ],
        verify: (_) {
          verify(() => watchFacultiesMock(null)).called(1);
        },
      );

      blocTest<FacultiesBloc, FacultiesState>(
        'emits [LoadingFaculties, FacultiesFailure] '
        'when SubscriptionRequested is added '
        'and WatchFacultiesUseCase emits failure',
        setUp: () {
          when(() => watchFacultiesMock(null)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const SubscriptionRequested()),
        expect: () => <FacultiesState>[
          const LoadingFaculties(),
          FacultiesFailure(AppException.test()),
        ],
      );
    });
  });
}
