import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../program/domain/mocks.dart';

void main() {
  final lecturer = Lecturer(
    id: 'id',
    programId: programsMock.first.id,
    name: 'name',
    pangkatGolongan: 'III/a',
  );
  final lecturerUI = LecturerUI(
    id: lecturer.id,
    programId: lecturer.programId,
    name: lecturer.name,
    pangkatGolongan: lecturer.pangkatGolongan,
    program: programsMock.first,
  );
  late WatchSingleLecturerUseCase watchSingleLecturerMock;
  late WatchProgramsUseCase watchProgramsMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    watchSingleLecturerMock = getIt<WatchSingleLecturerUseCase>();
    when(() => watchSingleLecturerMock(lecturer.id))
        .thenAnswer((_) => Stream.value(AppResult.success(lecturer)));

    watchProgramsMock = getIt<WatchProgramsUseCase>();
    when(() => watchProgramsMock(null))
        .thenAnswer((_) => Stream.value(AppResult.success(programsMock)));
  });

  tearDown(() {
    reset(watchSingleLecturerMock);
    reset(watchProgramsMock);
  });

  LecturerDetailBloc buildBloc() {
    return LecturerDetailBloc(
      watchSingleLecturer: watchSingleLecturerMock,
      watchPrograms: watchProgramsMock,
    );
  }

  group('LecturerDetailBloc', () {
    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const LecturerDetailInitial());
    });

    group('LecturerDetailSubscriptionRequested', () {
      blocTest<LecturerDetailBloc, LecturerDetailState>(
        'emits [LoadingLecturerDetail, LecturerDetailLoaded] '
        'when LecturerDetailSubscriptionRequested is added and '
        'WatchSingleLecturerUseCase and WatchProgramsUseCase emits success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          LecturerDetailSubscriptionRequested(id: lecturer.id),
        ),
        expect: () => <LecturerDetailState>[
          const LoadingLecturerDetail(),
          LecturerDetailLoaded(lecturer: lecturerUI),
        ],
        verify: (_) {
          verify(() => watchSingleLecturerMock(lecturer.id)).called(1);
          verify(() => watchProgramsMock(null)).called(1);
        },
      );

      blocTest<LecturerDetailBloc, LecturerDetailState>(
        'emits [LoadingLecturerDetail, LecturerDetailLoadFailed] '
        'when LecturerDetailSubscriptionRequested is added and '
        'WatchSingleLecturerUseCase emits failure',
        setUp: () {
          when(() => watchSingleLecturerMock(lecturer.id)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          LecturerDetailSubscriptionRequested(id: lecturer.id),
        ),
        expect: () => <LecturerDetailState>[
          const LoadingLecturerDetail(),
          LecturerDetailLoadFailed(exception: AppException.test()),
        ],
        verify: (_) {
          verify(() => watchSingleLecturerMock(lecturer.id)).called(1);
        },
      );

      blocTest<LecturerDetailBloc, LecturerDetailState>(
        'emits [LoadingLecturerDetail, LecturerDetailLoadFailed] '
        'when LecturerDetailSubscriptionRequested is added and '
        'WatchProgramsUseCase emits failure',
        setUp: () {
          when(() => watchProgramsMock(null)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          LecturerDetailSubscriptionRequested(id: lecturer.id),
        ),
        expect: () => <LecturerDetailState>[
          const LoadingLecturerDetail(),
          LecturerDetailLoadFailed(exception: AppException.test()),
        ],
        verify: (_) {
          verify(() => watchSingleLecturerMock(lecturer.id)).called(1);
          verify(() => watchProgramsMock(null)).called(1);
        },
      );
    });
  });
}
