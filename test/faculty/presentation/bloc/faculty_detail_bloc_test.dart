import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../program/domain/mocks.dart';

void main() {
  const faculty = Faculty(id: 'id', name: 'name');
  late WatchSingleFacultyUseCase watchSingleFacultyMock;
  late WatchProgramsByFacultyUseCase watchProgramsByFacultyMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    watchSingleFacultyMock = getIt<WatchSingleFacultyUseCase>();
    watchProgramsByFacultyMock = getIt<WatchProgramsByFacultyUseCase>();

    when(() => watchSingleFacultyMock(faculty.id))
        .thenAnswer((_) => Stream.value(AppResult.success(faculty)));
    when(() => watchProgramsByFacultyMock(faculty.id))
        .thenAnswer((_) => Stream.value(AppResult.success(programsMock)));
  });

  tearDown(() {
    reset(watchSingleFacultyMock);
    reset(watchProgramsByFacultyMock);
  });

  FacultyDetailBloc buildBloc() {
    return FacultyDetailBloc(
      watchSingleFaculty: watchSingleFacultyMock,
      watchProgramsByFaculty: watchProgramsByFacultyMock,
    );
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
        'use cases emit success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          FacultyDetailSubscriptionRequested(id: faculty.id),
        ),
        expect: () => <FacultyDetailState>[
          const LoadingFacultyDetail(),
          FacultyDetailLoaded(faculty: faculty, programs: programsMock),
        ],
        verify: (_) {
          verify(() => watchSingleFacultyMock(faculty.id)).called(1);
          verify(() => watchProgramsByFacultyMock(faculty.id)).called(1);
        },
      );

      blocTest<FacultyDetailBloc, FacultyDetailState>(
        'emits [LoadingFacultyDetail, FacultyDetailLoadFailed] '
        'when FacultyDetailSubscriptionRequested is added and '
        'WatchSingleFacultyUseCase emits failure',
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
          verify(() => watchProgramsByFacultyMock(faculty.id)).called(1);
        },
      );

      blocTest<FacultyDetailBloc, FacultyDetailState>(
        'emits [LoadingFacultyDetail, FacultyDetailLoadFailed] '
        'when FacultyDetailSubscriptionRequested is added and '
        'WatchProgramsByFacultyUseCase emits failure',
        setUp: () {
          when(() => watchProgramsByFacultyMock(faculty.id)).thenAnswer(
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
          verify(() => watchProgramsByFacultyMock(faculty.id)).called(1);
        },
      );
    });
  });
}
