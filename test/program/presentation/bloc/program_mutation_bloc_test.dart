// ignore_for_file: avoid_redundant_argument_values need verbosity on test

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';

void main() {
  const program = Program(id: 'id', facultyId: 'faculty_1', name: 'name');
  late CreateProgramUseCase createProgramMock;

  group('ProgramMutationBloc', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      createProgramMock = getIt<CreateProgramUseCase>();
    });

    ProgramMutationBloc buildBloc() {
      return ProgramMutationBloc(
        createProgram: createProgramMock,
      );
    }

    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const ProgramMutationState());
    });

    group('ProgramMutationCreateRequested', () {
      const params = CreateProgramParams(facultyId: 'faculty_1', name: 'name');

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => createProgramMock(params))
            .thenAnswer((_) async => AppResult.success(program));
      });

      blocTest<ProgramMutationBloc, ProgramMutationState>(
        'emits [isCreating true, created notice and isCreating false] '
        'when ProgramMutationCreateRequested is added '
        'and CreateProgramUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          ProgramMutationCreateRequested(
            facultyId: params.facultyId,
            name: params.name,
          ),
        ),
        expect: () => const <ProgramMutationState>[
          ProgramMutationState(isCreating: true),
          ProgramMutationState(
            isCreating: false,
            notice: ProgramCreatedNotice(program),
          ),
        ],
        verify: (_) {
          verify(() => createProgramMock(params)).called(1);
        },
      );

      blocTest<ProgramMutationBloc, ProgramMutationState>(
        'emits [isCreating true, failed notice and isCreating false] '
        'when ProgramMutationCreateRequested is added '
        'and CreateProgramUseCase fail',
        setUp: () {
          when(() => createProgramMock(params))
              .thenAnswer((_) async => AppResult.failure(AppException.test()));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          ProgramMutationCreateRequested(
            facultyId: params.facultyId,
            name: params.name,
          ),
        ),
        expect: () => <ProgramMutationState>[
          const ProgramMutationState(isCreating: true),
          ProgramMutationState(
            isCreating: false,
            notice: ProgramMutationFailedNotice(
              program: null,
              type: ProgramMutationType.create,
              exception: AppException.test(),
            ),
          ),
        ],
        verify: (_) {
          verify(() => createProgramMock(params)).called(1);
        },
      );
    });
  });
}
