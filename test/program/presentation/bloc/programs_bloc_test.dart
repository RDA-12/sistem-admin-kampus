import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';

void main() {
  final programs = List.generate(
    5,
    (index) => Program(
      id: '$index',
      facultyId: 'faculty_1',
      name: '$index',
    ),
  );

  group('ProgramsBloc', () {
    late WatchProgramsUseCase watchProgramsMock;

    setUpAll(initializeMockDependencies);

    setUp(() {
      watchProgramsMock = getIt<WatchProgramsUseCase>();
      when(() => watchProgramsMock(null))
          .thenAnswer((_) => Stream.value(AppResult.success(programs)));
    });

    ProgramsBloc buildBloc() {
      return ProgramsBloc(
        watchPrograms: watchProgramsMock,
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
        'and WatchProgramsUseCase emits success',
        build: buildBloc,
        act: (bloc) => bloc.add(const ProgramsSubscriptionRequested()),
        expect: () => <ProgramsState>[
          const LoadingPrograms(),
          ProgramsLoaded(programs),
        ],
        verify: (_) {
          verify(() => watchProgramsMock(null)).called(1);
        },
      );

      blocTest<ProgramsBloc, ProgramsState>(
        'emits [LoadingPrograms, ProgramsFailure] '
        'when ProgramsSubscriptionRequested is added '
        'and WatchProgramsUseCase emits failure',
        setUp: () {
          when(() => watchProgramsMock(null)).thenAnswer(
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
