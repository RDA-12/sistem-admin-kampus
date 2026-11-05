import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../faculty/domain/mocks.dart';

void main() {
  final programs = List.generate(
    5,
    (index) => ProgramUI(
      id: '$index',
      facultyId: facultyMock.id,
      name: '$index',
      faculty: facultyMock,
    ),
  );

  group('ProgramsBloc', () {
    late WatchFacultiesUseCase watchFacultiesMock;
    late WatchProgramsUseCase watchProgramsMock;

    setUpAll(initializeMockDependencies);

    setUp(() {
      watchProgramsMock = getIt<WatchProgramsUseCase>();
      when(() => watchProgramsMock()).thenAnswer(
        (_) => Stream.value(
          AppResult.success([
            ...programs,
            const Program(id: 'id', facultyId: 'facultyId', name: 'name'),
          ]),
        ),
      );

      watchFacultiesMock = getIt<WatchFacultiesUseCase>();
      when(() => watchFacultiesMock(null))
          .thenAnswer((_) => Stream.value(AppResult.success([facultyMock])));
    });

    ProgramsBloc buildBloc() {
      return ProgramsBloc(
        watchPrograms: watchProgramsMock,
        watchFaculties: watchFacultiesMock,
      );
    }

    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const ProgramsInitial());
    });

    group('ProgramsSubscriptionRequested', () {
      blocTest<ProgramsBloc, ProgramsState>(
        'emits [LoadingPrograms, ProgramsLoaded] '
        'when ProgramsSubscriptionRequested is added '
        'and WatchProgramsUseCase and WatchFacultiesUseCase emits success',
        build: buildBloc,
        act: (bloc) => bloc.add(const ProgramsSubscriptionRequested()),
        expect: () => <ProgramsState>[
          const LoadingPrograms(),
          ProgramsLoaded(programs),
        ],
        verify: (_) {
          verify(() => watchProgramsMock()).called(1);
        },
      );

      blocTest<ProgramsBloc, ProgramsState>(
        'emits [LoadingPrograms, ProgramsFailure] '
        'when ProgramsSubscriptionRequested is added '
        'and WatchFacultiesUseCase emits failure',
        setUp: () {
          when(() => watchFacultiesMock(null)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ProgramsSubscriptionRequested()),
        expect: () => <ProgramsState>[
          const LoadingPrograms(),
          ProgramsFailure(AppException.test()),
        ],
      );

      blocTest<ProgramsBloc, ProgramsState>(
        'emits [LoadingPrograms, ProgramsFailure] '
        'when ProgramsSubscriptionRequested is added '
        'and WatchProgramsUseCase emits failure',
        setUp: () {
          when(() => watchProgramsMock()).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ProgramsSubscriptionRequested()),
        expect: () => <ProgramsState>[
          const LoadingPrograms(),
          ProgramsFailure(AppException.test()),
        ],
      );
    });
  });
}
