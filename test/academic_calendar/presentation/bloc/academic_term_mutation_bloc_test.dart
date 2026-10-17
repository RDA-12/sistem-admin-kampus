// ignore_for_file: avoid_redundant_argument_values need verbosity on test

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';

void main() {
  final term = AcademicTerm(
    id: 'id',
    academicYearId: 'year_1',
    name: 'Ganjil',
    startDate: DateTime(2025, 9),
    endDate: DateTime(2026, 1, 31),
  );
  late CreateAcademicTermUseCase createAcademicTermMock;
  late UpdateAcademicTermUseCase updateAcademicTermMock;
  late DeleteAcademicTermUseCase deleteAcademicTermMock;

  group('AcademicTermMutationBloc', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      createAcademicTermMock = getIt<CreateAcademicTermUseCase>();
      updateAcademicTermMock = getIt<UpdateAcademicTermUseCase>();
      deleteAcademicTermMock = getIt<DeleteAcademicTermUseCase>();
    });

    AcademicTermMutationBloc buildBloc() {
      return AcademicTermMutationBloc(
        createAcademicTerm: createAcademicTermMock,
        updateAcademicTerm: updateAcademicTermMock,
        deleteAcademicTerm: deleteAcademicTermMock,
      );
    }

    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const AcademicTermMutationState());
    });

    group('AcademicTermMutationCreateRequested', () {
      final params = CreateAcademicTermParams(
        academicYearId: 'year_1',
        name: 'Ganjil',
        startDate: DateTime(2025, 9),
        endDate: DateTime(2026, 1, 31),
      );

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => createAcademicTermMock(params))
            .thenAnswer((_) async => AppResult.success(term));
      });

      blocTest<AcademicTermMutationBloc, AcademicTermMutationState>(
        'emits [isCreating true, created notice and isCreating false] '
        'when AcademicTermMutationCreateRequested is added '
        'and CreateAcademicTermUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicTermMutationCreateRequested(
            academicYearId: params.academicYearId,
            name: params.name,
            startDate: params.startDate,
            endDate: params.endDate,
          ),
        ),
        expect: () => <AcademicTermMutationState>[
          const AcademicTermMutationState(isCreating: true),
          AcademicTermMutationState(
            isCreating: false,
            notice: AcademicTermCreatedNotice(term),
          ),
        ],
        verify: (_) {
          verify(() => createAcademicTermMock(params)).called(1);
        },
      );

      blocTest<AcademicTermMutationBloc, AcademicTermMutationState>(
        'emits [isCreating true, failure notice and isCreating false] '
        'when AcademicTermMutationCreateRequested is added '
        'and CreateAcademicTermUseCase fails',
        setUp: () {
          when(() => createAcademicTermMock(params)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicTermMutationCreateRequested(
            academicYearId: params.academicYearId,
            name: params.name,
            startDate: params.startDate,
            endDate: params.endDate,
          ),
        ),
        expect: () => <AcademicTermMutationState>[
          const AcademicTermMutationState(isCreating: true),
          AcademicTermMutationState(
            isCreating: false,
            notice: AcademicTermMutationFailedNotice(
              type: AcademicTermMutationType.create,
              exception: AppException.test(),
              academicTerm: null,
            ),
          ),
        ],
        verify: (_) {
          verify(() => createAcademicTermMock(params)).called(1);
        },
      );
    });

    group('AcademicTermMutationUpdateRequested', () {
      final updatedTerm = AcademicTerm(
        id: 'id',
        academicYearId: 'year_2',
        name: 'Genap',
        startDate: DateTime(2026, 2),
        endDate: DateTime(2026, 6, 30),
      );
      final params = UpdateAcademicTermParams(
        term,
        academicYearId: 'year_2',
        name: 'Genap',
        startDate: DateTime(2026, 2),
        endDate: DateTime(2026, 6, 30),
      );

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => updateAcademicTermMock(params))
            .thenAnswer((_) async => AppResult.success(updatedTerm));
      });

      blocTest<AcademicTermMutationBloc, AcademicTermMutationState>(
        'emits [updatingIds with id, updated notice and empty updatingIds] '
        'when AcademicTermMutationUpdateRequested is added '
        'and UpdateAcademicTermUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicTermMutationUpdateRequested(
            academicTerm: term,
            academicYearId: 'year_2',
            name: 'Genap',
            startDate: DateTime(2026, 2),
            endDate: DateTime(2026, 6, 30),
          ),
        ),
        expect: () => <AcademicTermMutationState>[
          const AcademicTermMutationState(updatingIds: {'id'}),
          AcademicTermMutationState(
            updatingIds: const {},
            notice: AcademicTermUpdatedNotice(
              before: term,
              after: updatedTerm,
            ),
          ),
        ],
        verify: (_) {
          verify(() => updateAcademicTermMock(params)).called(1);
        },
      );

      blocTest<AcademicTermMutationBloc, AcademicTermMutationState>(
        'emits [updatingIds with id, failure notice and empty updatingIds] '
        'when AcademicTermMutationUpdateRequested is added '
        'and UpdateAcademicTermUseCase fails',
        setUp: () {
          when(() => updateAcademicTermMock(params)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicTermMutationUpdateRequested(
            academicTerm: term,
            academicYearId: 'year_2',
            name: 'Genap',
            startDate: DateTime(2026, 2),
            endDate: DateTime(2026, 6, 30),
          ),
        ),
        expect: () => <AcademicTermMutationState>[
          const AcademicTermMutationState(updatingIds: {'id'}),
          AcademicTermMutationState(
            updatingIds: const {},
            notice: AcademicTermMutationFailedNotice(
              type: AcademicTermMutationType.update,
              exception: AppException.test(),
              academicTerm: term,
            ),
          ),
        ],
        verify: (_) {
          verify(() => updateAcademicTermMock(params)).called(1);
        },
      );
    });

    group('AcademicTermMutationDeleteRequested', () {
      setUpAll(() {
        registerFallbackValue(term);
      });

      setUp(() {
        when(() => deleteAcademicTermMock(term))
            .thenAnswer((_) async => AppResult.success(null));
      });

      blocTest<AcademicTermMutationBloc, AcademicTermMutationState>(
        'emits [deletingIds with id, deleted notice and empty deletingIds] '
        'when AcademicTermMutationDeleteRequested is added '
        'and DeleteAcademicTermUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicTermMutationDeleteRequested(academicTerm: term),
        ),
        expect: () => <AcademicTermMutationState>[
          const AcademicTermMutationState(deletingIds: {'id'}),
          AcademicTermMutationState(
            deletingIds: const {},
            notice: AcademicTermDeletedNotice(term),
          ),
        ],
        verify: (_) {
          verify(() => deleteAcademicTermMock(term)).called(1);
        },
      );

      blocTest<AcademicTermMutationBloc, AcademicTermMutationState>(
        'emits [deletingIds with id, failure notice and empty deletingIds] '
        'when AcademicTermMutationDeleteRequested is added '
        'and DeleteAcademicTermUseCase fails',
        setUp: () {
          when(() => deleteAcademicTermMock(term)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicTermMutationDeleteRequested(academicTerm: term),
        ),
        expect: () => <AcademicTermMutationState>[
          const AcademicTermMutationState(deletingIds: {'id'}),
          AcademicTermMutationState(
            deletingIds: const {},
            notice: AcademicTermMutationFailedNotice(
              type: AcademicTermMutationType.delete,
              exception: AppException.test(),
              academicTerm: term,
            ),
          ),
        ],
        verify: (_) {
          verify(() => deleteAcademicTermMock(term)).called(1);
        },
      );
    });
  });
}
