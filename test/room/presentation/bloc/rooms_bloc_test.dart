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
  final rooms = List.generate(
    5,
    (index) => RoomUI(
      id: '$index',
      facultyId: facultyMock.id,
      name: 'Room $index',
      faculty: facultyMock,
    ),
  );

  group('RoomsBloc', () {
    late WatchFacultiesUseCase watchFacultiesMock;
    late WatchRoomsUseCase watchRoomsMock;

    setUpAll(initializeMockDependencies);

    setUp(() {
      watchRoomsMock = getIt<WatchRoomsUseCase>();
      when(() => watchRoomsMock(null)).thenAnswer(
        (_) => Stream.value(
          AppResult.success([
            ...rooms,
            const Room(
              id: 'id',
              facultyId: 'facultyId',
              name: 'name',
            ),
          ]),
        ),
      );

      watchFacultiesMock = getIt<WatchFacultiesUseCase>();
      when(() => watchFacultiesMock(null))
          .thenAnswer((_) => Stream.value(AppResult.success([facultyMock])));
    });

    RoomsBloc buildBloc() {
      return RoomsBloc(
        watchRooms: watchRoomsMock,
        watchFaculties: watchFacultiesMock,
      );
    }

    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const RoomsInitial());
    });

    group('RoomsSubscriptionRequested', () {
      blocTest<RoomsBloc, RoomsState>(
        'emits [LoadingRooms, RoomsLoaded] '
        'when RoomsSubscriptionRequested is added '
        'and WatchRoomsUseCase and WatchFacultiesUseCase emits success',
        build: buildBloc,
        act: (bloc) => bloc.add(const RoomsSubscriptionRequested()),
        expect: () => <RoomsState>[
          const LoadingRooms(),
          RoomsLoaded(rooms),
        ],
        verify: (_) {
          verify(() => watchRoomsMock(null)).called(1);
        },
      );

      blocTest<RoomsBloc, RoomsState>(
        'emits [LoadingRooms, RoomsFailure] '
        'when RoomsSubscriptionRequested is added '
        'and WatchFacultiesUseCase emits failure',
        setUp: () {
          when(() => watchFacultiesMock(null)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const RoomsSubscriptionRequested()),
        expect: () => <RoomsState>[
          const LoadingRooms(),
          RoomsFailure(AppException.test()),
        ],
      );

      blocTest<RoomsBloc, RoomsState>(
        'emits [LoadingRooms, RoomsFailure] '
        'when RoomsSubscriptionRequested is added '
        'and WatchRoomsUseCase emits failure',
        setUp: () {
          when(() => watchRoomsMock(null)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const RoomsSubscriptionRequested()),
        expect: () => <RoomsState>[
          const LoadingRooms(),
          RoomsFailure(AppException.test()),
        ],
      );
    });
  });
}
