import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';

void main() {
  const program = Program(id: 'id', facultyId: 'faculty_1', name: 'name');
  late WatchSingleProgramUseCase watchSingleProgramMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    watchSingleProgramMock = getIt<WatchSingleProgramUseCase>();
    when(() => watchSingleProgramMock(program.id))
        .thenAnswer((_) => Stream.value(AppResult.success(program)));
  });

  tearDown(() {
    reset(watchSingleProgramMock);
  });

  ProgramDetailBloc buildBloc() {
    return ProgramDetailBloc(watchSingleProgram: watchSingleProgramMock);
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
        'WatchSingleProgramUseCase emits success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          ProgramDetailSubscriptionRequested(id: program.id),
        ),
        expect: () => const <ProgramDetailState>[
          LoadingProgramDetail(),
          ProgramDetailLoaded(program: program),
        ],
        verify: (_) {
          verify(() => watchSingleProgramMock(program.id)).called(1);
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
        },
      );
    });
  });
}
