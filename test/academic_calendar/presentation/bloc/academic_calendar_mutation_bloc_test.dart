// Test names and arguments in bloc tests require descriptive length and verbosity.
// ignore_for_file: avoid_redundant_argument_values, lines_longer_than_80_chars

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
  final term = AcademicTerm(
    id: 'term_id',
    academicYearId: 'id',
    name: 'Ganjil',
    startDate: DateTime(2025, 9),
    endDate: DateTime(2026, 1, 31),
  );

  late CreateAcademicYearUseCase createAcademicYearMock;
  late UpdateAcademicYearUseCase updateAcademicYearMock;
  late DeleteAcademicYearUseCase deleteAcademicYearMock;
  late CreateAcademicTermUseCase createAcademicTermMock;
  late UpdateAcademicTermUseCase updateAcademicTermMock;
  late DeleteAcademicTermUseCase deleteAcademicTermMock;

  group('AcademicCalendarMutationBloc', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      createAcademicYearMock = getIt<CreateAcademicYearUseCase>();
      updateAcademicYearMock = getIt<UpdateAcademicYearUseCase>();
      deleteAcademicYearMock = getIt<DeleteAcademicYearUseCase>();
      createAcademicTermMock = getIt<CreateAcademicTermUseCase>();
      updateAcademicTermMock = getIt<UpdateAcademicTermUseCase>();
      deleteAcademicTermMock = getIt<DeleteAcademicTermUseCase>();
    });

    AcademicCalendarMutationBloc buildBloc() {
      return AcademicCalendarMutationBloc(
        createAcademicYear: createAcademicYearMock,
        updateAcademicYear: updateAcademicYearMock,
        deleteAcademicYear: deleteAcademicYearMock,
        createAcademicTerm: createAcademicTermMock,
        updateAcademicTerm: updateAcademicTermMock,
        deleteAcademicTerm: deleteAcademicTermMock,
      );
    }

    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const AcademicCalendarMutationState());
    });

    group('AcademicCalendarYearCreateRequested', () {
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

      blocTest<AcademicCalendarMutationBloc, AcademicCalendarMutationState>(
        'emits [isCreatingYear true, created notice and isCreatingYear false] '
        'when AcademicCalendarYearCreateRequested is added '
        'and CreateAcademicYearUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicCalendarYearCreateRequested(
            name: params.name,
            startDate: params.startDate,
            endDate: params.endDate,
          ),
        ),
        expect: () => <AcademicCalendarMutationState>[
          const AcademicCalendarMutationState(isCreatingYear: true),
          AcademicCalendarMutationState(
            isCreatingYear: false,
            notice: AcademicYearCreatedNotice(year),
          ),
        ],
        verify: (_) {
          verify(() => createAcademicYearMock(params)).called(1);
        },
      );

      blocTest<AcademicCalendarMutationBloc, AcademicCalendarMutationState>(
        'emits [isCreatingYear true, failure notice and isCreatingYear false] '
        'when AcademicCalendarYearCreateRequested is added '
        'and CreateAcademicYearUseCase fails',
        setUp: () {
          when(() => createAcademicYearMock(params)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicCalendarYearCreateRequested(
            name: params.name,
            startDate: params.startDate,
            endDate: params.endDate,
          ),
        ),
        expect: () => <AcademicCalendarMutationState>[
          const AcademicCalendarMutationState(isCreatingYear: true),
          AcademicCalendarMutationState(
            isCreatingYear: false,
            notice: AcademicCalendarMutationFailedNotice(
              type: AcademicCalendarMutationType.create,
              target: AcademicCalendarTargetType.year,
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

    group('AcademicCalendarYearUpdateRequested', () {
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

      blocTest<AcademicCalendarMutationBloc, AcademicCalendarMutationState>(
        'emits [updatingYearIds with id, updated notice and empty updatingYearIds] '
        'when AcademicCalendarYearUpdateRequested is added '
        'and UpdateAcademicYearUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicCalendarYearUpdateRequested(
            academicYear: year,
            name: '2026/2027',
            startDate: DateTime(2026, 9),
            endDate: DateTime(2027, 8, 31),
          ),
        ),
        expect: () => <AcademicCalendarMutationState>[
          const AcademicCalendarMutationState(updatingYearIds: {'id'}),
          AcademicCalendarMutationState(
            updatingYearIds: const {},
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

      blocTest<AcademicCalendarMutationBloc, AcademicCalendarMutationState>(
        'emits [updatingYearIds with id, failure notice and empty updatingYearIds] '
        'when AcademicCalendarYearUpdateRequested is added '
        'and UpdateAcademicYearUseCase fails',
        setUp: () {
          when(() => updateAcademicYearMock(params)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicCalendarYearUpdateRequested(
            academicYear: year,
            name: '2026/2027',
            startDate: DateTime(2026, 9),
            endDate: DateTime(2027, 8, 31),
          ),
        ),
        expect: () => <AcademicCalendarMutationState>[
          const AcademicCalendarMutationState(updatingYearIds: {'id'}),
          AcademicCalendarMutationState(
            updatingYearIds: const {},
            notice: AcademicCalendarMutationFailedNotice(
              type: AcademicCalendarMutationType.update,
              target: AcademicCalendarTargetType.year,
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

    group('AcademicCalendarYearDeleteRequested', () {
      setUpAll(() {
        registerFallbackValue(year);
      });

      setUp(() {
        when(() => deleteAcademicYearMock(year))
            .thenAnswer((_) async => AppResult.success(null));
      });

      blocTest<AcademicCalendarMutationBloc, AcademicCalendarMutationState>(
        'emits [deletingYearIds with id, deleted notice and empty deletingYearIds] '
        'when AcademicCalendarYearDeleteRequested is added '
        'and DeleteAcademicYearUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicCalendarYearDeleteRequested(academicYear: year),
        ),
        expect: () => <AcademicCalendarMutationState>[
          const AcademicCalendarMutationState(deletingYearIds: {'id'}),
          AcademicCalendarMutationState(
            deletingYearIds: const {},
            notice: AcademicYearDeletedNotice(year),
          ),
        ],
        verify: (_) {
          verify(() => deleteAcademicYearMock(year)).called(1);
        },
      );

      blocTest<AcademicCalendarMutationBloc, AcademicCalendarMutationState>(
        'emits [deletingYearIds with id, failure notice and empty deletingYearIds] '
        'when AcademicCalendarYearDeleteRequested is added '
        'and DeleteAcademicYearUseCase fails',
        setUp: () {
          when(() => deleteAcademicYearMock(year)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicCalendarYearDeleteRequested(academicYear: year),
        ),
        expect: () => <AcademicCalendarMutationState>[
          const AcademicCalendarMutationState(deletingYearIds: {'id'}),
          AcademicCalendarMutationState(
            deletingYearIds: const {},
            notice: AcademicCalendarMutationFailedNotice(
              type: AcademicCalendarMutationType.delete,
              target: AcademicCalendarTargetType.year,
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

    group('AcademicCalendarTermCreateRequested', () {
      final params = CreateAcademicTermParams(
        academicYearId: 'id',
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

      blocTest<AcademicCalendarMutationBloc, AcademicCalendarMutationState>(
        'emits [isCreatingTerm true, created notice and isCreatingTerm false] '
        'when AcademicCalendarTermCreateRequested is added '
        'and CreateAcademicTermUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicCalendarTermCreateRequested(
            academicYearId: params.academicYearId,
            name: params.name,
            startDate: params.startDate,
            endDate: params.endDate,
          ),
        ),
        expect: () => <AcademicCalendarMutationState>[
          const AcademicCalendarMutationState(isCreatingTerm: true),
          AcademicCalendarMutationState(
            isCreatingTerm: false,
            notice: AcademicTermCreatedNotice(term),
          ),
        ],
        verify: (_) {
          verify(() => createAcademicTermMock(params)).called(1);
        },
      );

      blocTest<AcademicCalendarMutationBloc, AcademicCalendarMutationState>(
        'emits [isCreatingTerm true, failure notice and isCreatingTerm false] '
        'when AcademicCalendarTermCreateRequested is added '
        'and CreateAcademicTermUseCase fails',
        setUp: () {
          when(() => createAcademicTermMock(params)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicCalendarTermCreateRequested(
            academicYearId: params.academicYearId,
            name: params.name,
            startDate: params.startDate,
            endDate: params.endDate,
          ),
        ),
        expect: () => <AcademicCalendarMutationState>[
          const AcademicCalendarMutationState(isCreatingTerm: true),
          AcademicCalendarMutationState(
            isCreatingTerm: false,
            notice: AcademicCalendarMutationFailedNotice(
              type: AcademicCalendarMutationType.create,
              target: AcademicCalendarTargetType.term,
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

    group('AcademicCalendarTermUpdateRequested', () {
      final updatedTerm = AcademicTerm(
        id: 'term_id',
        academicYearId: 'id',
        name: 'Genap',
        startDate: DateTime(2026, 2),
        endDate: DateTime(2026, 7, 31),
      );
      final params = UpdateAcademicTermParams(
        term,
        academicYearId: 'id',
        name: 'Genap',
        startDate: DateTime(2026, 2),
        endDate: DateTime(2026, 7, 31),
      );

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => updateAcademicTermMock(params))
            .thenAnswer((_) async => AppResult.success(updatedTerm));
      });

      blocTest<AcademicCalendarMutationBloc, AcademicCalendarMutationState>(
        'emits [updatingTermIds with id, updated notice and empty updatingTermIds] '
        'when AcademicCalendarTermUpdateRequested is added '
        'and UpdateAcademicTermUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicCalendarTermUpdateRequested(
            academicTerm: term,
            academicYearId: 'id',
            name: 'Genap',
            startDate: DateTime(2026, 2),
            endDate: DateTime(2026, 7, 31),
          ),
        ),
        expect: () => <AcademicCalendarMutationState>[
          const AcademicCalendarMutationState(updatingTermIds: {'term_id'}),
          AcademicCalendarMutationState(
            updatingTermIds: const {},
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

      blocTest<AcademicCalendarMutationBloc, AcademicCalendarMutationState>(
        'emits [updatingTermIds with id, failure notice and empty updatingTermIds] '
        'when AcademicCalendarTermUpdateRequested is added '
        'and UpdateAcademicTermUseCase fails',
        setUp: () {
          when(() => updateAcademicTermMock(params)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicCalendarTermUpdateRequested(
            academicTerm: term,
            academicYearId: 'id',
            name: 'Genap',
            startDate: DateTime(2026, 2),
            endDate: DateTime(2026, 7, 31),
          ),
        ),
        expect: () => <AcademicCalendarMutationState>[
          const AcademicCalendarMutationState(updatingTermIds: {'term_id'}),
          AcademicCalendarMutationState(
            updatingTermIds: const {},
            notice: AcademicCalendarMutationFailedNotice(
              type: AcademicCalendarMutationType.update,
              target: AcademicCalendarTargetType.term,
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

    group('AcademicCalendarTermDeleteRequested', () {
      setUpAll(() {
        registerFallbackValue(term);
      });

      setUp(() {
        when(() => deleteAcademicTermMock(term))
            .thenAnswer((_) async => AppResult.success(null));
      });

      blocTest<AcademicCalendarMutationBloc, AcademicCalendarMutationState>(
        'emits [deletingTermIds with id, deleted notice and empty deletingTermIds] '
        'when AcademicCalendarTermDeleteRequested is added '
        'and DeleteAcademicTermUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicCalendarTermDeleteRequested(academicTerm: term),
        ),
        expect: () => <AcademicCalendarMutationState>[
          const AcademicCalendarMutationState(deletingTermIds: {'term_id'}),
          AcademicCalendarMutationState(
            deletingTermIds: const {},
            notice: AcademicTermDeletedNotice(term),
          ),
        ],
        verify: (_) {
          verify(() => deleteAcademicTermMock(term)).called(1);
        },
      );

      blocTest<AcademicCalendarMutationBloc, AcademicCalendarMutationState>(
        'emits [deletingTermIds with id, failure notice and empty deletingTermIds] '
        'when AcademicCalendarTermDeleteRequested is added '
        'and DeleteAcademicTermUseCase fails',
        setUp: () {
          when(() => deleteAcademicTermMock(term)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          AcademicCalendarTermDeleteRequested(academicTerm: term),
        ),
        expect: () => <AcademicCalendarMutationState>[
          const AcademicCalendarMutationState(deletingTermIds: {'term_id'}),
          AcademicCalendarMutationState(
            deletingTermIds: const {},
            notice: AcademicCalendarMutationFailedNotice(
              type: AcademicCalendarMutationType.delete,
              target: AcademicCalendarTargetType.term,
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
