// ignore_for_file: avoid_redundant_argument_values need verbosity on test

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/room/room.dart';

import '../../../common/di_mocks.dart';

void main() {
  const room = Room(
    id: 'id',
    facultyId: 'faculty_1',
    name: 'name',
  );
  late CreateRoomUseCase createRoomMock;
  late UpdateRoomUseCase updateRoomMock;
  late DeleteRoomUseCase deleteRoomMock;

  group('RoomMutationBloc', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      createRoomMock = getIt<CreateRoomUseCase>();
      updateRoomMock = getIt<UpdateRoomUseCase>();
      deleteRoomMock = getIt<DeleteRoomUseCase>();
    });

    RoomMutationBloc buildBloc() {
      return RoomMutationBloc(
        createRoom: createRoomMock,
        updateRoom: updateRoomMock,
        deleteRoom: deleteRoomMock,
      );
    }

    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const RoomMutationState());
    });

    group('RoomMutationCreateRequested', () {
      const params = CreateRoomParams(
        facultyId: 'faculty_1',
        name: 'name',
      );

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => createRoomMock(params))
            .thenAnswer((_) async => AppResult.success(room));
      });

      blocTest<RoomMutationBloc, RoomMutationState>(
        'emits [isCreating true, created notice and isCreating false] '
        'when RoomMutationCreateRequested is added '
        'and CreateRoomUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          RoomMutationCreateRequested(
            facultyId: params.facultyId,
            name: params.name,
          ),
        ),
        expect: () => <RoomMutationState>[
          const RoomMutationState(isCreating: true),
          const RoomMutationState(
            isCreating: false,
            notice: RoomCreatedNotice(room),
          ),
        ],
        verify: (_) {
          verify(() => createRoomMock(params)).called(1);
        },
      );

      blocTest<RoomMutationBloc, RoomMutationState>(
        'emits [isCreating true, failure notice and isCreating false] '
        'when RoomMutationCreateRequested is added '
        'and CreateRoomUseCase fails',
        setUp: () {
          when(() => createRoomMock(params))
              .thenAnswer((_) async => AppResult.failure(AppException.test()));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          RoomMutationCreateRequested(
            facultyId: params.facultyId,
            name: params.name,
          ),
        ),
        expect: () => <RoomMutationState>[
          const RoomMutationState(isCreating: true),
          RoomMutationState(
            isCreating: false,
            notice: RoomMutationFailedNotice(
              type: RoomMutationType.create,
              exception: AppException.test(),
              room: null,
            ),
          ),
        ],
        verify: (_) {
          verify(() => createRoomMock(params)).called(1);
        },
      );
    });

    group('RoomMutationUpdateRequested', () {
      const updatedRoom = Room(
        id: 'id',
        facultyId: 'faculty_2',
        name: 'updated',
      );
      const params = UpdateRoomParams(
        room,
        name: 'updated',
        facultyId: 'faculty_2',
      );

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => updateRoomMock(params))
            .thenAnswer((_) async => AppResult.success(updatedRoom));
      });

      blocTest<RoomMutationBloc, RoomMutationState>(
        'emits [updatingIds with id, updated notice and empty updatingIds] '
        'when RoomMutationUpdateRequested is added '
        'and UpdateRoomUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          const RoomMutationUpdateRequested(
            room: room,
            name: 'updated',
            facultyId: 'faculty_2',
          ),
        ),
        expect: () => <RoomMutationState>[
          const RoomMutationState(updatingIds: {'id'}),
          const RoomMutationState(
            updatingIds: {},
            notice: RoomUpdatedNotice(
              before: room,
              after: updatedRoom,
            ),
          ),
        ],
        verify: (_) {
          verify(() => updateRoomMock(params)).called(1);
        },
      );

      blocTest<RoomMutationBloc, RoomMutationState>(
        'emits [updatingIds with id, failure notice and empty updatingIds] '
        'when RoomMutationUpdateRequested is added '
        'and UpdateRoomUseCase fails',
        setUp: () {
          when(() => updateRoomMock(params))
              .thenAnswer((_) async => AppResult.failure(AppException.test()));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const RoomMutationUpdateRequested(
            room: room,
            name: 'updated',
            facultyId: 'faculty_2',
          ),
        ),
        expect: () => <RoomMutationState>[
          const RoomMutationState(updatingIds: {'id'}),
          RoomMutationState(
            updatingIds: const {},
            notice: RoomMutationFailedNotice(
              type: RoomMutationType.update,
              exception: AppException.test(),
              room: room,
            ),
          ),
        ],
        verify: (_) {
          verify(() => updateRoomMock(params)).called(1);
        },
      );
    });

    group('RoomMutationDeleteRequested', () {
      setUpAll(() {
        registerFallbackValue(room);
      });

      setUp(() {
        when(() => deleteRoomMock(room))
            .thenAnswer((_) async => AppResult.success(null));
      });

      blocTest<RoomMutationBloc, RoomMutationState>(
        'emits [deletingIds with id, deleted notice and empty deletingIds] '
        'when RoomMutationDeleteRequested is added '
        'and DeleteRoomUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          const RoomMutationDeleteRequested(room: room),
        ),
        expect: () => <RoomMutationState>[
          const RoomMutationState(deletingIds: {'id'}),
          const RoomMutationState(
            deletingIds: {},
            notice: RoomDeletedNotice(room),
          ),
        ],
        verify: (_) {
          verify(() => deleteRoomMock(room)).called(1);
        },
      );

      blocTest<RoomMutationBloc, RoomMutationState>(
        'emits [deletingIds with id, failure notice and empty deletingIds] '
        'when RoomMutationDeleteRequested is added '
        'and DeleteRoomUseCase fails',
        setUp: () {
          when(() => deleteRoomMock(room))
              .thenAnswer((_) async => AppResult.failure(AppException.test()));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const RoomMutationDeleteRequested(room: room),
        ),
        expect: () => <RoomMutationState>[
          const RoomMutationState(deletingIds: {'id'}),
          RoomMutationState(
            deletingIds: const {},
            notice: RoomMutationFailedNotice(
              type: RoomMutationType.delete,
              exception: AppException.test(),
              room: room,
            ),
          ),
        ],
        verify: (_) {
          verify(() => deleteRoomMock(room)).called(1);
        },
      );
    });
  });
}
