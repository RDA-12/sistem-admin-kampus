// ignore_for_file: avoid_redundant_argument_values need verbosity on test

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';

void main() {
  final year = AcademicYear(
    id: 'id',
    name: '2025/2026',
    startDate: DateTime(2025, 9),
    endDate: DateTime(2026, 8, 31),
  );
  late CreateAcademicYearUseCase createAcademicYearMock;
  late UpdateAcademicYearUseCase updateAcademicYearMock;
  late DeleteAcademicYearUseCase deleteAcademicYearMock;

  group('AcademicYearMutationBloc', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      createAcademicYearMock = getIt<CreateAcademicYearUseCase>();
      updateAcademicYearMock = getIt<UpdateAcademicYearUseCase>();
      deleteAcademicYearMock = getIt<DeleteAcademicYearUseCase>();
    });

    AcademicYearMutationBloc buildBloc() {
      return AcademicYearMutationBloc(
        createAcademicYear: createAcademicYearMock,
        updateAcademicYear: updateAcademicYearMock,
        deleteAcademicYear: deleteAcademicYearMock,
      );
    }

    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const AcademicYearMutationState());
    });

    group('AcademicYearMutationCreateRequested', () {
      final params = CreateAcademicYearParams(
        name: '2025/2026',
        startDate: DateTime(2025, 9),
        endDate: DateTime(2026, 8, 31),
      );

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => createAcademicYearMock(params))
            .thenAnswer((_) async => AppResult.success(year));
      });

      blocTest<AcademicYearMutationBloc, AcademicYearMutationState>(
        'emits [isCreating true, created notice and isCreating false] '
        'when AcademicYearMutationCreateRequested is added '
        'and CreateAcademicYearUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicYearMutationCreateRequested(
            name: params.name,
            startDate: params.startDate,
            endDate: params.endDate,
          ),
        ),
        expect: () => <AcademicYearMutationState>[
          const AcademicYearMutationState(isCreating: true),
          AcademicYearMutationState(
            isCreating: false,
            notice: AcademicYearCreatedNotice(year),
          ),
        ],
        verify: (_) {
          verify(() => createAcademicYearMock(params)).called(1);
        },
      );

      blocTest<AcademicYearMutationBloc, AcademicYearMutationState>(
        'emits [isCreating true, failure notice and isCreating false] '
        'when AcademicYearMutationCreateRequested is added '
        'and CreateAcademicYearUseCase fails',
        setUp: () {
          when(() => createAcademicYearMock(params)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicYearMutationCreateRequested(
            name: params.name,
            startDate: params.startDate,
            endDate: params.endDate,
          ),
        ),
        expect: () => <AcademicYearMutationState>[
          const AcademicYearMutationState(isCreating: true),
          AcademicYearMutationState(
            isCreating: false,
            notice: AcademicYearMutationFailedNotice(
              type: AcademicYearMutationType.create,
              exception: AppException.test(),
              academicYear: null,
            ),
          ),
        ],
        verify: (_) {
          verify(() => createAcademicYearMock(params)).called(1);
        },
      );
    });

    group('AcademicYearMutationUpdateRequested', () {
      final updatedYear = AcademicYear(
        id: 'id',
        name: '2026/2027',
        startDate: DateTime(2026, 9),
        endDate: DateTime(2027, 8, 31),
      );
      final params = UpdateAcademicYearParams(
        year,
        name: '2026/2027',
        startDate: DateTime(2026, 9),
        endDate: DateTime(2027, 8, 31),
      );

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => updateAcademicYearMock(params))
            .thenAnswer((_) async => AppResult.success(updatedYear));
      });

      blocTest<AcademicYearMutationBloc, AcademicYearMutationState>(
        'emits [updatingIds with id, updated notice and empty updatingIds] '
        'when AcademicYearMutationUpdateRequested is added '
        'and UpdateAcademicYearUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicYearMutationUpdateRequested(
            academicYear: year,
            name: '2026/2027',
            startDate: DateTime(2026, 9),
            endDate: DateTime(2027, 8, 31),
          ),
        ),
        expect: () => <AcademicYearMutationState>[
          const AcademicYearMutationState(updatingIds: {'id'}),
          AcademicYearMutationState(
            updatingIds: const {},
            notice: AcademicYearUpdatedNotice(
              before: year,
              after: updatedYear,
            ),
          ),
        ],
        verify: (_) {
          verify(() => updateAcademicYearMock(params)).called(1);
        },
      );

      blocTest<AcademicYearMutationBloc, AcademicYearMutationState>(
        'emits [updatingIds with id, failure notice and empty updatingIds] '
        'when AcademicYearMutationUpdateRequested is added '
        'and UpdateAcademicYearUseCase fails',
        setUp: () {
          when(() => updateAcademicYearMock(params)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicYearMutationUpdateRequested(
            academicYear: year,
            name: '2026/2027',
            startDate: DateTime(2026, 9),
            endDate: DateTime(2027, 8, 31),
          ),
        ),
        expect: () => <AcademicYearMutationState>[
          const AcademicYearMutationState(updatingIds: {'id'}),
          AcademicYearMutationState(
            updatingIds: const {},
            notice: AcademicYearMutationFailedNotice(
              type: AcademicYearMutationType.update,
              exception: AppException.test(),
              academicYear: year,
            ),
          ),
        ],
        verify: (_) {
          verify(() => updateAcademicYearMock(params)).called(1);
        },
      );
    });

    group('AcademicYearMutationDeleteRequested', () {
      setUpAll(() {
        registerFallbackValue(year);
      });

      setUp(() {
        when(() => deleteAcademicYearMock(year))
            .thenAnswer((_) async => AppResult.success(null));
      });

      blocTest<AcademicYearMutationBloc, AcademicYearMutationState>(
        'emits [deletingIds with id, deleted notice and empty deletingIds] '
        'when AcademicYearMutationDeleteRequested is added '
        'and DeleteAcademicYearUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicYearMutationDeleteRequested(academicYear: year),
        ),
        expect: () => <AcademicYearMutationState>[
          const AcademicYearMutationState(deletingIds: {'id'}),
          AcademicYearMutationState(
            deletingIds: const {},
            notice: AcademicYearDeletedNotice(year),
          ),
        ],
        verify: (_) {
          verify(() => deleteAcademicYearMock(year)).called(1);
        },
      );

      blocTest<AcademicYearMutationBloc, AcademicYearMutationState>(
        'emits [deletingIds with id, failure notice and empty deletingIds] '
        'when AcademicYearMutationDeleteRequested is added '
        'and DeleteAcademicYearUseCase fails',
        setUp: () {
          when(() => deleteAcademicYearMock(year)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicYearMutationDeleteRequested(academicYear: year),
        ),
        expect: () => <AcademicYearMutationState>[
          const AcademicYearMutationState(deletingIds: {'id'}),
          AcademicYearMutationState(
            deletingIds: const {},
            notice: AcademicYearMutationFailedNotice(
              type: AcademicYearMutationType.delete,
              exception: AppException.test(),
              academicYear: year,
            ),
          ),
        ],
        verify: (_) {
          verify(() => deleteAcademicYearMock(year)).called(1);
        },
      );
    });
  });
}
