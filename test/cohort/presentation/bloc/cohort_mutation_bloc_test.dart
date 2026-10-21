// ignore_for_file: avoid_redundant_argument_values need verbosity on test

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';
import '../../domain/mocks.dart';

void main() {
  late CreateCohortUseCase createCohortMock;
  late UpdateCohortUseCase updateCohortMock;
  late DeleteCohortUseCase deleteCohortMock;

  group('CohortMutationBloc', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      createCohortMock = getIt<CreateCohortUseCase>();
      updateCohortMock = getIt<UpdateCohortUseCase>();
      deleteCohortMock = getIt<DeleteCohortUseCase>();
    });

    CohortMutationBloc buildBloc() {
      return CohortMutationBloc(
        createCohort: createCohortMock,
        updateCohort: updateCohortMock,
        deleteCohort: deleteCohortMock,
      );
    }

    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const CohortMutationState());
    });

    group('CohortMutationCreateRequested', () {
      final params = CreateCohortParams(
        name: cohortMock.name,
        entryYear: cohortMock.entryYear,
      );

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => createCohortMock(params))
            .thenAnswer((_) async => AppResult.success(cohortMock));
      });

      blocTest<CohortMutationBloc, CohortMutationState>(
        'emits [isCreating true, created notice and isCreating false] '
        'when CohortMutationCreateRequested is added '
        'and CreateCohortUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          CohortMutationCreateRequested(
            name: params.name,
            entryYear: params.entryYear,
          ),
        ),
        expect: () => const <CohortMutationState>[
          CohortMutationState(isCreating: true),
          CohortMutationState(
            isCreating: false,
            notice: CohortCreatedNotice(cohortMock),
          ),
        ],
        verify: (_) {
          verify(() => createCohortMock(params)).called(1);
        },
      );

      blocTest<CohortMutationBloc, CohortMutationState>(
        'emits [isCreating true, failure notice and isCreating false] '
        'when CohortMutationCreateRequested is added '
        'and CreateCohortUseCase fails',
        setUp: () {
          when(() => createCohortMock(params)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          CohortMutationCreateRequested(
            name: params.name,
            entryYear: params.entryYear,
          ),
        ),
        expect: () => <CohortMutationState>[
          const CohortMutationState(isCreating: true),
          CohortMutationState(
            isCreating: false,
            notice: CohortMutationFailedNotice(
              type: CohortMutationType.create,
              exception: AppException.test(),
              cohort: null,
            ),
          ),
        ],
        verify: (_) {
          verify(() => createCohortMock(params)).called(1);
        },
      );
    });

    group('CohortMutationUpdateRequested', () {
      final updatedCohort = Cohort(
        id: cohortMock.id,
        name: 'Cohort 2026',
        entryYear: 2026,
      );
      const params = UpdateCohortParams(
        cohortMock,
        name: 'Cohort 2026',
        entryYear: 2026,
      );

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => updateCohortMock(params))
            .thenAnswer((_) async => AppResult.success(updatedCohort));
      });

      blocTest<CohortMutationBloc, CohortMutationState>(
        'emits [updatingIds with id, updated notice and empty updatingIds] '
        'when CohortMutationUpdateRequested is added '
        'and UpdateCohortUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          const CohortMutationUpdateRequested(
            cohort: cohortMock,
            name: 'Cohort 2026',
            entryYear: 2026,
          ),
        ),
        expect: () => <CohortMutationState>[
          CohortMutationState(updatingIds: {cohortMock.id}),
          CohortMutationState(
            updatingIds: const {},
            notice: CohortUpdatedNotice(
              before: cohortMock,
              after: updatedCohort,
            ),
          ),
        ],
        verify: (_) {
          verify(() => updateCohortMock(params)).called(1);
        },
      );

      blocTest<CohortMutationBloc, CohortMutationState>(
        'emits [updatingIds with id, failure notice and empty updatingIds] '
        'when CohortMutationUpdateRequested is added '
        'and UpdateCohortUseCase fails',
        setUp: () {
          when(() => updateCohortMock(params)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const CohortMutationUpdateRequested(
            cohort: cohortMock,
            name: 'Cohort 2026',
            entryYear: 2026,
          ),
        ),
        expect: () => <CohortMutationState>[
          CohortMutationState(updatingIds: {cohortMock.id}),
          CohortMutationState(
            updatingIds: const {},
            notice: CohortMutationFailedNotice(
              type: CohortMutationType.update,
              exception: AppException.test(),
              cohort: cohortMock,
            ),
          ),
        ],
        verify: (_) {
          verify(() => updateCohortMock(params)).called(1);
        },
      );
    });

    group('CohortMutationDeleteRequested', () {
      setUpAll(() {
        registerFallbackValue(cohortMock);
      });

      setUp(() {
        when(() => deleteCohortMock(cohortMock))
            .thenAnswer((_) async => AppResult.success(null));
      });

      blocTest<CohortMutationBloc, CohortMutationState>(
        'emits [deletingIds with id, deleted notice and empty deletingIds] '
        'when CohortMutationDeleteRequested is added '
        'and DeleteCohortUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          const CohortMutationDeleteRequested(cohort: cohortMock),
        ),
        expect: () => <CohortMutationState>[
          CohortMutationState(deletingIds: {cohortMock.id}),
          const CohortMutationState(
            deletingIds: {},
            notice: CohortDeletedNotice(cohortMock),
          ),
        ],
        verify: (_) {
          verify(() => deleteCohortMock(cohortMock)).called(1);
        },
      );

      blocTest<CohortMutationBloc, CohortMutationState>(
        'emits [deletingIds with id, failure notice and empty deletingIds] '
        'when CohortMutationDeleteRequested is added '
        'and DeleteCohortUseCase fails',
        setUp: () {
          when(() => deleteCohortMock(cohortMock)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const CohortMutationDeleteRequested(cohort: cohortMock),
        ),
        expect: () => <CohortMutationState>[
          CohortMutationState(deletingIds: {cohortMock.id}),
          CohortMutationState(
            deletingIds: const {},
            notice: CohortMutationFailedNotice(
              type: CohortMutationType.delete,
              exception: AppException.test(),
              cohort: cohortMock,
            ),
          ),
        ],
        verify: (_) {
          verify(() => deleteCohortMock(cohortMock)).called(1);
        },
      );
    });
  });
}
