import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/room/room.dart';

import '../../../common/di_mocks.dart';
import '../../../faculty/domain/mocks.dart';

void main() {
  final room = Room(
    id: 'id',
    facultyId: facultiesMock.first.id,
    name: 'name',
  );
  final roomUI = RoomUI(
    id: room.id,
    facultyId: room.facultyId,
    name: room.name,
    faculty: facultiesMock.first,
  );
  late WatchSingleRoomUseCase watchSingleRoomMock;
  late WatchFacultiesUseCase watchFacultiesMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    watchSingleRoomMock = getIt<WatchSingleRoomUseCase>();
    when(() => watchSingleRoomMock(room.id))
        .thenAnswer((_) => Stream.value(AppResult.success(room)));

    watchFacultiesMock = getIt<WatchFacultiesUseCase>();
    when(() => watchFacultiesMock(null))
        .thenAnswer((_) => Stream.value(AppResult.success(facultiesMock)));
  });

  tearDown(() {
    reset(watchSingleRoomMock);
    reset(watchFacultiesMock);
  });

  RoomDetailBloc buildBloc() {
    return RoomDetailBloc(
      watchSingleRoom: watchSingleRoomMock,
      watchFaculties: watchFacultiesMock,
    );
  }

  group('RoomDetailBloc', () {
    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const RoomDetailInitial());
    });

    group('RoomDetailSubscriptionRequested', () {
      blocTest<RoomDetailBloc, RoomDetailState>(
        'emits [LoadingRoomDetail, RoomDetailLoaded] '
        'when RoomDetailSubscriptionRequested is added and '
        'WatchSingleRoomUseCase and WatchFacultiesUseCase emits success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          RoomDetailSubscriptionRequested(id: room.id),
        ),
        expect: () => <RoomDetailState>[
          const LoadingRoomDetail(),
          RoomDetailLoaded(room: roomUI),
        ],
        verify: (_) {
          verify(() => watchSingleRoomMock(room.id)).called(1);
          verify(() => watchFacultiesMock(null)).called(1);
        },
      );

      blocTest<RoomDetailBloc, RoomDetailState>(
        'emits [LoadingRoomDetail, RoomDetailLoadFailed] '
        'when RoomDetailSubscriptionRequested is added and '
        'WatchSingleRoomUseCase emits failure',
        setUp: () {
          when(() => watchSingleRoomMock(room.id)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          RoomDetailSubscriptionRequested(id: room.id),
        ),
        expect: () => <RoomDetailState>[
          const LoadingRoomDetail(),
          RoomDetailLoadFailed(exception: AppException.test()),
        ],
        verify: (_) {
          verify(() => watchSingleRoomMock(room.id)).called(1);
        },
      );

      blocTest<RoomDetailBloc, RoomDetailState>(
        'emits [LoadingRoomDetail, RoomDetailLoadFailed] '
        'when RoomDetailSubscriptionRequested is added and '
        'WatchFacultiesUseCase emits failure',
        setUp: () {
          when(() => watchFacultiesMock(null)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          RoomDetailSubscriptionRequested(id: room.id),
        ),
        expect: () => <RoomDetailState>[
          const LoadingRoomDetail(),
          RoomDetailLoadFailed(exception: AppException.test()),
        ],
        verify: (_) {
          verify(() => watchSingleRoomMock(room.id)).called(1);
          verify(() => watchFacultiesMock(null)).called(1);
        },
      );
    });
  });
}
