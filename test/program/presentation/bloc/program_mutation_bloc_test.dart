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
  late UpdateProgramUseCase updateProgramMock;

  group('ProgramMutationBloc', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      createProgramMock = getIt<CreateProgramUseCase>();
      updateProgramMock = getIt<UpdateProgramUseCase>();
    });

    ProgramMutationBloc buildBloc() {
      return ProgramMutationBloc(
        createProgram: createProgramMock,
        updateProgram: updateProgramMock,
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

    group('ProgramMutationUpdateRequested', () {
      const params = UpdateProgramParams(program, name: 'new name');
      const updated = Program(
        id: 'id',
        facultyId: 'faculty_1',
        name: 'new name',
      );

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => updateProgramMock(params))
            .thenAnswer((_) async => AppResult.success(updated));
      });

      blocTest<ProgramMutationBloc, ProgramMutationState>(
        'emits [added updatingIds, updated notice and removed updatingIds] '
        'when ProgramMutationUpdateRequested is added '
        'and UpdateProgramUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          ProgramMutationUpdateRequested(program: program, name: params.name),
        ),
        expect: () => <ProgramMutationState>[
          ProgramMutationState(updatingIds: {program.id}),
          const ProgramMutationState(
            updatingIds: {},
            notice: ProgramUpdatedNotice(
              before: program,
              after: updated,
            ),
          ),
        ],
        verify: (_) {
          verify(() => updateProgramMock(params)).called(1);
        },
      );

      blocTest<ProgramMutationBloc, ProgramMutationState>(
        'emits [added updatingIds, failed notice and removed updatingIds] '
        'when ProgramMutationUpdateRequested is added '
        'and UpdateProgramUseCase fail',
        setUp: () {
          when(() => updateProgramMock(params))
              .thenAnswer((_) async => AppResult.failure(AppException.test()));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          ProgramMutationUpdateRequested(program: program, name: params.name),
        ),
        expect: () => <ProgramMutationState>[
          ProgramMutationState(updatingIds: {program.id}),
          ProgramMutationState(
            updatingIds: const {},
            notice: ProgramMutationFailedNotice(
              program: program,
              type: ProgramMutationType.update,
              exception: AppException.test(),
            ),
          ),
        ],
        verify: (_) {
          verify(() => updateProgramMock(params)).called(1);
        },
      );
    });
  });
}
