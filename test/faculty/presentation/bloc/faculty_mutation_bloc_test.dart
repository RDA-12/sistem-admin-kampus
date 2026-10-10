// ignore_for_file: avoid_redundant_argument_values need verbosity on test

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../../common/di_mocks.dart';

void main() {
  const faculty = Faculty(id: 'id', name: 'name');
  late CreateFacultyUseCase createFacultyMock;
  late UpdateFacultyUseCase updateFacultyMock;
  late DeleteFacultyUseCase deleteFacultyMock;

  group('FacultyMutationBloc', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      createFacultyMock = getIt<CreateFacultyUseCase>();
      updateFacultyMock = getIt<UpdateFacultyUseCase>();
      deleteFacultyMock = getIt<DeleteFacultyUseCase>();
    });

    FacultyMutationBloc buildBloc() {
      return FacultyMutationBloc(
        createFaculty: createFacultyMock,
        updateFaculty: updateFacultyMock,
        deleteFaculty: deleteFacultyMock,
      );
    }

    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const FacultyMutationState());
    });

    group('FacultyMutationCreateRequested', () {
      const params = CreateFacultyParams(name: 'name');

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => createFacultyMock(params))
            .thenAnswer((_) async => AppResult.success(faculty));
      });

      blocTest<FacultyMutationBloc, FacultyMutationState>(
        'emits [isCreating true, created notice and isCreating false] '
        'when FacultyMutationCreateRequested is added '
        'and CreateFacultyUseCase success',
        build: buildBloc,
        act: (bloc) =>
            bloc.add(FacultyMutationCreateRequested(name: params.name)),
        expect: () => const <FacultyMutationState>[
          FacultyMutationState(isCreating: true),
          FacultyMutationState(
            isCreating: false,
            notice: FacultyCreatedNotice(faculty),
          ),
        ],
        verify: (_) {
          verify(() => createFacultyMock(params)).called(1);
        },
      );

      blocTest<FacultyMutationBloc, FacultyMutationState>(
        'emits [isCreating true, failed notice and isCreating false] '
        'when FacultyMutationCreateRequested is added '
        'and CreateFacultyUseCase fail',
        setUp: () {
          when(() => createFacultyMock(params))
              .thenAnswer((_) async => AppResult.failure(AppException.test()));
        },
        build: buildBloc,
        act: (bloc) =>
            bloc.add(FacultyMutationCreateRequested(name: params.name)),
        expect: () => <FacultyMutationState>[
          const FacultyMutationState(isCreating: true),
          FacultyMutationState(
            isCreating: false,
            notice: FacultyMutationFailedNotice(
              faculty: null,
              type: .create,
              exception: AppException.test(),
            ),
          ),
        ],
        verify: (_) {
          verify(() => createFacultyMock(params)).called(1);
        },
      );
    });

    group('FacultyMutationUpdateRequested', () {
      const params = UpdateFacultyParams(faculty, name: 'new name');
      const updated = Faculty(id: 'id', name: 'new name');

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => updateFacultyMock(params))
            .thenAnswer((_) async => AppResult.success(updated));
      });

      blocTest<FacultyMutationBloc, FacultyMutationState>(
        'emits [added updatingIds, updated notice and removed updatingIds] '
        'when FacultyMutationUpdateRequested is added '
        'and UpdateFacultyUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          FacultyMutationUpdateRequested(faculty: faculty, name: params.name),
        ),
        expect: () => <FacultyMutationState>[
          FacultyMutationState(updatingIds: {faculty.id}),
          const FacultyMutationState(
            updatingIds: {},
            notice: FacultyUpdatedNotice(
              before: faculty,
              after: updated,
            ),
          ),
        ],
        verify: (_) {
          verify(() => updateFacultyMock(params)).called(1);
        },
      );

      blocTest<FacultyMutationBloc, FacultyMutationState>(
        'emits [added updatingIds, failed notice and removed updatingIds] '
        'when FacultyMutationUpdateRequested is added '
        'and CreateFacultyUseCase fail',
        setUp: () {
          when(() => updateFacultyMock(params))
              .thenAnswer((_) async => AppResult.failure(AppException.test()));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          FacultyMutationUpdateRequested(faculty: faculty, name: params.name),
        ),
        expect: () => <FacultyMutationState>[
          FacultyMutationState(updatingIds: {faculty.id}),
          FacultyMutationState(
            updatingIds: const {},
            notice: FacultyMutationFailedNotice(
              faculty: faculty,
              type: .update,
              exception: AppException.test(),
            ),
          ),
        ],
        verify: (_) {
          verify(() => updateFacultyMock(params)).called(1);
        },
      );
    });

    group('FacultyMutationDeleteRequested', () {
      setUp(() {
        when(() => deleteFacultyMock(faculty))
            .thenAnswer((_) async => AppResult.success(null));
      });

      blocTest<FacultyMutationBloc, FacultyMutationState>(
        'emits [added deletingIds, updated notice and removed deletingIds] '
        'when FacultyMutationDeleteRequested is added '
        'and UpdateFacultyUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          const FacultyMutationDeleteRequested(faculty: faculty),
        ),
        expect: () => <FacultyMutationState>[
          FacultyMutationState(deletingIds: {faculty.id}),
          const FacultyMutationState(
            deletingIds: {},
            notice: FacultyDeletedNotice(faculty),
          ),
        ],
        verify: (_) {
          verify(() => deleteFacultyMock(faculty)).called(1);
        },
      );

      blocTest<FacultyMutationBloc, FacultyMutationState>(
        'emits [added deletingIds, failed notice and removed deletingIds] '
        'when FacultyMutationDeleteRequested is added '
        'and CreateFacultyUseCase fail',
        setUp: () {
          when(() => deleteFacultyMock(faculty))
              .thenAnswer((_) async => AppResult.failure(AppException.test()));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const FacultyMutationDeleteRequested(faculty: faculty),
        ),
        expect: () => <FacultyMutationState>[
          FacultyMutationState(deletingIds: {faculty.id}),
          FacultyMutationState(
            deletingIds: const {},
            notice: FacultyMutationFailedNotice(
              faculty: faculty,
              type: .delete,
              exception: AppException.test(),
            ),
          ),
        ],
        verify: (_) {
          verify(() => deleteFacultyMock(faculty)).called(1);
        },
      );
    });
  });
}
