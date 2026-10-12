import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../../common/di_mocks.dart';

void main() {
  const faculty = Faculty(id: 'id', name: 'name');
  late WatchSingleFacultyUseCase watchSingleFacultyMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    watchSingleFacultyMock = getIt<WatchSingleFacultyUseCase>();
    when(() => watchSingleFacultyMock(faculty.id))
        .thenAnswer((_) => Stream.value(AppResult.success(faculty)));
  });

  tearDown(() {
    reset(watchSingleFacultyMock);
  });

  FacultyDetailBloc buildBloc() {
    return FacultyDetailBloc(watchSingleFaculty: watchSingleFacultyMock);
  }

  group('FacultyDetailBloc', () {
    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const FacultyDetailInitial());
    });

    group('FacultyDetailSubsriptionRequested', () {
      blocTest<FacultyDetailBloc, FacultyDetailState>(
        'emits [LoadingFacultyDetail, FacultyDetailLoaded] '
        'when FacultyDetailSubscriptionRequested is added and '
        'WacthSingleFacultyUseCase emits success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          FacultyDetailSubscriptionRequested(id: faculty.id),
        ),
        expect: () => const <FacultyDetailState>[
          LoadingFacultyDetail(),
          FacultyDetailLoaded(faculty: faculty),
        ],
        verify: (_) {
          verify(() => watchSingleFacultyMock(faculty.id)).called(1);
        },
      );

      blocTest<FacultyDetailBloc, FacultyDetailState>(
        'emits [LoadingFacultyDetail, FacultyDetailLoadFailed] '
        'when FacultyDetailSubscriptionRequested is added and '
        'WacthSingleFacultyUseCase emits failure',
        setUp: () {
          when(() => watchSingleFacultyMock(faculty.id)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          FacultyDetailSubscriptionRequested(id: faculty.id),
        ),
        expect: () => <FacultyDetailState>[
          const LoadingFacultyDetail(),
          FacultyDetailLoadFailed(exception: AppException.test()),
        ],
        verify: (_) {
          verify(() => watchSingleFacultyMock(faculty.id)).called(1);
        },
      );
    });
  });
}
