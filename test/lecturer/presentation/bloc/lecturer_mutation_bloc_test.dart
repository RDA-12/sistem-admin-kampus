// ignore_for_file: avoid_redundant_argument_values need verbosity on test

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';

import '../../../common/di_mocks.dart';

void main() {
  const lecturer = Lecturer(
    id: 'id',
    programId: 'program_1',
    name: 'name',
    pangkatGolongan: 'III/a',
  );
  late CreateLecturerUseCase createLecturerMock;
  late UpdateLecturerUseCase updateLecturerMock;
  late DeleteLecturerUseCase deleteLecturerMock;

  group('LecturerMutationBloc', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      createLecturerMock = getIt<CreateLecturerUseCase>();
      updateLecturerMock = getIt<UpdateLecturerUseCase>();
      deleteLecturerMock = getIt<DeleteLecturerUseCase>();
    });

    LecturerMutationBloc buildBloc() {
      return LecturerMutationBloc(
        createLecturer: createLecturerMock,
        updateLecturer: updateLecturerMock,
        deleteLecturer: deleteLecturerMock,
      );
    }

    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const LecturerMutationState());
    });

    group('LecturerMutationCreateRequested', () {
      const params = CreateLecturerParams(
        programId: 'program_1',
        name: 'name',
        pangkatGolongan: 'III/a',
      );

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => createLecturerMock(params))
            .thenAnswer((_) async => AppResult.success(lecturer));
      });

      blocTest<LecturerMutationBloc, LecturerMutationState>(
        'emits [isCreating true, created notice and isCreating false] '
        'when LecturerMutationCreateRequested is added '
        'and CreateLecturerUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          LecturerMutationCreateRequested(
            programId: params.programId,
            name: params.name,
            pangkatGolongan: params.pangkatGolongan,
          ),
        ),
        expect: () => <LecturerMutationState>[
          const LecturerMutationState(isCreating: true),
          const LecturerMutationState(
            isCreating: false,
            notice: LecturerCreatedNotice(lecturer),
          ),
        ],
        verify: (_) {
          verify(() => createLecturerMock(params)).called(1);
        },
      );

      blocTest<LecturerMutationBloc, LecturerMutationState>(
        'emits [isCreating true, failure notice and isCreating false] '
        'when LecturerMutationCreateRequested is added '
        'and CreateLecturerUseCase fails',
        setUp: () {
          when(() => createLecturerMock(params))
              .thenAnswer((_) async => AppResult.failure(AppException.test()));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          LecturerMutationCreateRequested(
            programId: params.programId,
            name: params.name,
            pangkatGolongan: params.pangkatGolongan,
          ),
        ),
        expect: () => <LecturerMutationState>[
          const LecturerMutationState(isCreating: true),
          LecturerMutationState(
            isCreating: false,
            notice: LecturerMutationFailedNotice(
              type: LecturerMutationType.create,
              exception: AppException.test(),
              lecturer: null,
            ),
          ),
        ],
        verify: (_) {
          verify(() => createLecturerMock(params)).called(1);
        },
      );
    });

    group('LecturerMutationUpdateRequested', () {
      const updatedLecturer = Lecturer(
        id: 'id',
        programId: 'program_1',
        name: 'updated',
        pangkatGolongan: 'IV/a',
      );
      const params = UpdateLecturerParams(
        lecturer,
        name: 'updated',
        pangkatGolongan: 'IV/a',
      );

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => updateLecturerMock(params))
            .thenAnswer((_) async => AppResult.success(updatedLecturer));
      });

      blocTest<LecturerMutationBloc, LecturerMutationState>(
        'emits [updatingIds with id, updated notice and empty updatingIds] '
        'when LecturerMutationUpdateRequested is added '
        'and UpdateLecturerUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          const LecturerMutationUpdateRequested(
            lecturer: lecturer,
            name: 'updated',
            pangkatGolongan: 'IV/a',
          ),
        ),
        expect: () => <LecturerMutationState>[
          const LecturerMutationState(updatingIds: {'id'}),
          const LecturerMutationState(
            updatingIds: {},
            notice: LecturerUpdatedNotice(
              before: lecturer,
              after: updatedLecturer,
            ),
          ),
        ],
        verify: (_) {
          verify(() => updateLecturerMock(params)).called(1);
        },
      );

      blocTest<LecturerMutationBloc, LecturerMutationState>(
        'emits [updatingIds with id, failure notice and empty updatingIds] '
        'when LecturerMutationUpdateRequested is added '
        'and UpdateLecturerUseCase fails',
        setUp: () {
          when(() => updateLecturerMock(params))
              .thenAnswer((_) async => AppResult.failure(AppException.test()));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const LecturerMutationUpdateRequested(
            lecturer: lecturer,
            name: 'updated',
            pangkatGolongan: 'IV/a',
          ),
        ),
        expect: () => <LecturerMutationState>[
          const LecturerMutationState(updatingIds: {'id'}),
          LecturerMutationState(
            updatingIds: const {},
            notice: LecturerMutationFailedNotice(
              type: LecturerMutationType.update,
              exception: AppException.test(),
              lecturer: lecturer,
            ),
          ),
        ],
        verify: (_) {
          verify(() => updateLecturerMock(params)).called(1);
        },
      );
    });

    group('LecturerMutationDeleteRequested', () {
      setUpAll(() {
        registerFallbackValue(lecturer);
      });

      setUp(() {
        when(() => deleteLecturerMock(lecturer))
            .thenAnswer((_) async => AppResult.success(null));
      });

      blocTest<LecturerMutationBloc, LecturerMutationState>(
        'emits [deletingIds with id, deleted notice and empty deletingIds] '
        'when LecturerMutationDeleteRequested is added '
        'and DeleteLecturerUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          const LecturerMutationDeleteRequested(lecturer: lecturer),
        ),
        expect: () => <LecturerMutationState>[
          const LecturerMutationState(deletingIds: {'id'}),
          const LecturerMutationState(
            deletingIds: {},
            notice: LecturerDeletedNotice(lecturer),
          ),
        ],
        verify: (_) {
          verify(() => deleteLecturerMock(lecturer)).called(1);
        },
      );

      blocTest<LecturerMutationBloc, LecturerMutationState>(
        'emits [deletingIds with id, failure notice and empty deletingIds] '
        'when LecturerMutationDeleteRequested is added '
        'and DeleteLecturerUseCase fails',
        setUp: () {
          when(() => deleteLecturerMock(lecturer))
              .thenAnswer((_) async => AppResult.failure(AppException.test()));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const LecturerMutationDeleteRequested(lecturer: lecturer),
        ),
        expect: () => <LecturerMutationState>[
          const LecturerMutationState(deletingIds: {'id'}),
          LecturerMutationState(
            deletingIds: const {},
            notice: LecturerMutationFailedNotice(
              type: LecturerMutationType.delete,
              exception: AppException.test(),
              lecturer: lecturer,
            ),
          ),
        ],
        verify: (_) {
          verify(() => deleteLecturerMock(lecturer)).called(1);
        },
      );
    });
  });
}
