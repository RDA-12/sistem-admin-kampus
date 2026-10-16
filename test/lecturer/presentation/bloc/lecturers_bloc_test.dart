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
  final lecturers = List.generate(
    5,
    (index) => LecturerUI(
      id: '$index',
      programId: programMock.id,
      name: '$index',
      pangkatGolongan: 'III/a',
      program: programMock,
    ),
  );

  group('LecturersBloc', () {
    late WatchProgramsUseCase watchProgramsMock;
    late WatchLecturersUseCase watchLecturersMock;

    setUpAll(initializeMockDependencies);

    setUp(() {
      watchLecturersMock = getIt<WatchLecturersUseCase>();
      when(() => watchLecturersMock(null)).thenAnswer(
        (_) => Stream.value(
          AppResult.success([
            ...lecturers,
            const Lecturer(
              id: 'id',
              programId: 'programId',
              name: 'name',
              pangkatGolongan: 'III/a',
            ),
          ]),
        ),
      );

      watchProgramsMock = getIt<WatchProgramsUseCase>();
      when(() => watchProgramsMock(null))
          .thenAnswer((_) => Stream.value(AppResult.success([programMock])));
    });

    LecturersBloc buildBloc() {
      return LecturersBloc(
        watchLecturers: watchLecturersMock,
        watchPrograms: watchProgramsMock,
      );
    }

    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const LecturersInitial());
    });

    group('LecturersSubscriptionRequested', () {
      blocTest<LecturersBloc, LecturersState>(
        'emits [LoadingLecturers, LecturersLoaded] '
        'when LecturersSubscriptionRequested is added '
        'and WatchLecturersUseCase and WatchProgramsUseCase emits success',
        build: buildBloc,
        act: (bloc) => bloc.add(const LecturersSubscriptionRequested()),
        expect: () => <LecturersState>[
          const LoadingLecturers(),
          LecturersLoaded(lecturers),
        ],
        verify: (_) {
          verify(() => watchLecturersMock(null)).called(1);
        },
      );

      blocTest<LecturersBloc, LecturersState>(
        'emits [LoadingLecturers, LecturersFailure] '
        'when LecturersSubscriptionRequested is added '
        'and WatchProgramsUseCase emits failure',
        setUp: () {
          when(() => watchProgramsMock(null)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const LecturersSubscriptionRequested()),
        expect: () => <LecturersState>[
          const LoadingLecturers(),
          LecturersFailure(AppException.test()),
        ],
      );

      blocTest<LecturersBloc, LecturersState>(
        'emits [LoadingLecturers, LecturersFailure] '
        'when LecturersSubscriptionRequested is added '
        'and WatchLecturersUseCase emits failure',
        setUp: () {
          when(() => watchLecturersMock(null)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const LecturersSubscriptionRequested()),
        expect: () => <LecturersState>[
          const LoadingLecturers(),
          LecturersFailure(AppException.test()),
        ],
      );
    });
  });
}
