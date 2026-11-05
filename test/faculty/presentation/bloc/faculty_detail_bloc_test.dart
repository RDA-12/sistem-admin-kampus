import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/program/program.dart';
import 'package:sistem_admin/room/room.dart';

import '../../../common/di_mocks.dart';
import '../../../program/domain/mocks.dart';
import '../../../room/domain/mocks.dart';

void main() {
  const facultyId = 'id';
  const faculty = Faculty(id: facultyId, name: 'name');
  const programFilter = ProgramFilter(facultyId: facultyId);
  const roomFilter = RoomFilter(facultyId: facultyId);

  late WatchSingleFacultyUseCase watchSingleFacultyMock;
  late WatchProgramsUseCase watchProgramsMock;
  late WatchRoomsUseCase watchRoomsMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    watchSingleFacultyMock = getIt<WatchSingleFacultyUseCase>();
    watchProgramsMock = getIt<WatchProgramsUseCase>();
    watchRoomsMock = getIt<WatchRoomsUseCase>();

    when(() => watchSingleFacultyMock(faculty.id))
        .thenAnswer((_) => Stream.value(AppResult.success(faculty)));
    when(() => watchProgramsMock(programFilter))
        .thenAnswer((_) => Stream.value(AppResult.success(programsMock)));
    when(() => watchRoomsMock(roomFilter))
        .thenAnswer((_) => Stream.value(AppResult.success(roomsMock)));
  });

  tearDown(() {
    reset(watchSingleFacultyMock);
    reset(watchProgramsMock);
    reset(watchRoomsMock);
  });

  FacultyDetailBloc buildBloc() {
    return FacultyDetailBloc(
      watchSingleFaculty: watchSingleFacultyMock,
      watchPrograms: watchProgramsMock,
      watchRooms: watchRoomsMock,
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
          FacultyDetailLoaded(
            faculty: faculty,
            programs: programsMock,
            rooms: roomsMock,
          ),
        ],
        verify: (_) {
          verify(() => watchSingleFacultyMock(faculty.id)).called(1);
          verify(() => watchProgramsMock(programFilter)).called(1);
          verify(() => watchRoomsMock(roomFilter)).called(1);
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
          verify(() => watchProgramsMock(programFilter)).called(1);
          verify(() => watchRoomsMock(roomFilter)).called(1);
        },
      );

      blocTest<FacultyDetailBloc, FacultyDetailState>(
        'emits [LoadingFacultyDetail, FacultyDetailLoadFailed] '
        'when FacultyDetailSubscriptionRequested is added and '
        'WatchProgramsUseCase emits failure',
        setUp: () {
          when(() => watchProgramsMock(programFilter)).thenAnswer(
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
          verify(() => watchProgramsMock(programFilter)).called(1);
          verify(() => watchRoomsMock(roomFilter)).called(1);
        },
      );

      blocTest<FacultyDetailBloc, FacultyDetailState>(
        'emits [LoadingFacultyDetail, FacultyDetailLoadFailed] '
        'when FacultyDetailSubscriptionRequested is added and '
        'WatchRoomsUseCase emits failure',
        setUp: () {
          when(() => watchRoomsMock(roomFilter)).thenAnswer(
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
          verify(() => watchProgramsMock(programFilter)).called(1);
          verify(() => watchRoomsMock(roomFilter)).called(1);
        },
      );
    });
  });
}
