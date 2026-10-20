import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../course/domain/mocks.dart';
import '../../../faculty/domain/mocks.dart';
import '../../../lecturer/domain/mocks.dart';

void main() {
  final program = Program(
    id: 'id',
    facultyId: facultiesMock.first.id,
    name: 'name',
  );
  final programUI = ProgramUI(
    id: program.id,
    facultyId: program.facultyId,
    name: program.name,
    faculty: facultiesMock.first,
  );
  late WatchSingleProgramUseCase watchSingleProgramMock;
  late WatchFacultiesUseCase watchFacultiesMock;
  late WatchLecturersByProgramUseCase watchLecturersByProgramMock;
  late WatchCoursesByProgramUseCase watchCoursesByProgramMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    watchSingleProgramMock = getIt<WatchSingleProgramUseCase>();
    when(() => watchSingleProgramMock(program.id))
        .thenAnswer((_) => Stream.value(AppResult.success(program)));

    watchFacultiesMock = getIt<WatchFacultiesUseCase>();
    when(() => watchFacultiesMock(null))
        .thenAnswer((_) => Stream.value(AppResult.success(facultiesMock)));

    watchLecturersByProgramMock = getIt<WatchLecturersByProgramUseCase>();
    when(() => watchLecturersByProgramMock(program.id))
        .thenAnswer((_) => Stream.value(AppResult.success(lecturersMock)));

    watchCoursesByProgramMock = getIt<WatchCoursesByProgramUseCase>();
    when(() => watchCoursesByProgramMock(program.id))
        .thenAnswer((_) => Stream.value(AppResult.success(coursesMock)));
  });

  tearDown(() {
    reset(watchSingleProgramMock);
    reset(watchFacultiesMock);
    reset(watchLecturersByProgramMock);
    reset(watchCoursesByProgramMock);
  });

  ProgramDetailBloc buildBloc() {
    return ProgramDetailBloc(
      watchSingleProgram: watchSingleProgramMock,
      watchFaculties: watchFacultiesMock,
      watchLecturersByProgram: watchLecturersByProgramMock,
      watchCoursesByProgram: watchCoursesByProgramMock,
    );
  }

  group('ProgramDetailBloc', () {
    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const ProgramDetailInitial());
    });

    group('ProgramDetailSubscriptionRequested', () {
      blocTest<ProgramDetailBloc, ProgramDetailState>(
        'emits [LoadingProgramDetail, ProgramDetailLoaded] '
        'when ProgramDetailSubscriptionRequested is added and '
        'use cases emit success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          ProgramDetailSubscriptionRequested(id: program.id),
        ),
        expect: () => <ProgramDetailState>[
          const LoadingProgramDetail(),
          ProgramDetailLoaded(
            program: programUI,
            lecturers: lecturersMock,
            courses: coursesMock,
          ),
        ],
        verify: (_) {
          verify(() => watchSingleProgramMock(program.id)).called(1);
          verify(() => watchFacultiesMock(null)).called(1);
          verify(() => watchLecturersByProgramMock(program.id)).called(1);
          verify(() => watchCoursesByProgramMock(program.id)).called(1);
        },
      );

      blocTest<ProgramDetailBloc, ProgramDetailState>(
        'emits [LoadingProgramDetail, ProgramDetailLoadFailed] '
        'when ProgramDetailSubscriptionRequested is added and '
        'WatchSingleProgramUseCase emits failure',
        setUp: () {
          when(() => watchSingleProgramMock(program.id)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          ProgramDetailSubscriptionRequested(id: program.id),
        ),
        expect: () => <ProgramDetailState>[
          const LoadingProgramDetail(),
          ProgramDetailLoadFailed(exception: AppException.test()),
        ],
        verify: (_) {
          verify(() => watchSingleProgramMock(program.id)).called(1);
          verify(() => watchFacultiesMock(null)).called(1);
          verify(() => watchLecturersByProgramMock(program.id)).called(1);
          verify(() => watchCoursesByProgramMock(program.id)).called(1);
        },
      );

      blocTest<ProgramDetailBloc, ProgramDetailState>(
        'emits [LoadingProgramDetail, ProgramDetailLoadFailed] '
        'when ProgramDetailSubscriptionRequested is added and '
        'WatchFacultiesUseCase emits failure',
        setUp: () {
          when(() => watchFacultiesMock(null)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          ProgramDetailSubscriptionRequested(id: program.id),
        ),
        expect: () => <ProgramDetailState>[
          const LoadingProgramDetail(),
          ProgramDetailLoadFailed(exception: AppException.test()),
        ],
        verify: (_) {
          verify(() => watchSingleProgramMock(program.id)).called(1);
          verify(() => watchFacultiesMock(null)).called(1);
          verify(() => watchLecturersByProgramMock(program.id)).called(1);
          verify(() => watchCoursesByProgramMock(program.id)).called(1);
        },
      );

      blocTest<ProgramDetailBloc, ProgramDetailState>(
        'emits [LoadingProgramDetail, ProgramDetailLoadFailed] '
        'when ProgramDetailSubscriptionRequested is added and '
        'WatchLecturersByProgramUseCase emits failure',
        setUp: () {
          when(() => watchLecturersByProgramMock(program.id)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          ProgramDetailSubscriptionRequested(id: program.id),
        ),
        expect: () => <ProgramDetailState>[
          const LoadingProgramDetail(),
          ProgramDetailLoadFailed(exception: AppException.test()),
        ],
        verify: (_) {
          verify(() => watchSingleProgramMock(program.id)).called(1);
          verify(() => watchFacultiesMock(null)).called(1);
          verify(() => watchLecturersByProgramMock(program.id)).called(1);
          verify(() => watchCoursesByProgramMock(program.id)).called(1);
        },
      );

      blocTest<ProgramDetailBloc, ProgramDetailState>(
        'emits [LoadingProgramDetail, ProgramDetailLoadFailed] '
        'when ProgramDetailSubscriptionRequested is added and '
        'WatchCoursesByProgramUseCase emits failure',
        setUp: () {
          when(() => watchCoursesByProgramMock(program.id)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          ProgramDetailSubscriptionRequested(id: program.id),
        ),
        expect: () => <ProgramDetailState>[
          const LoadingProgramDetail(),
          ProgramDetailLoadFailed(exception: AppException.test()),
        ],
        verify: (_) {
          verify(() => watchSingleProgramMock(program.id)).called(1);
          verify(() => watchFacultiesMock(null)).called(1);
          verify(() => watchLecturersByProgramMock(program.id)).called(1);
          verify(() => watchCoursesByProgramMock(program.id)).called(1);
        },
      );
    });
  });
}
