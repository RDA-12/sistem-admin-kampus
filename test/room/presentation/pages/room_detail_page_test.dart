import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/room/room.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../../faculty/domain/mocks.dart';
import '../../domain/mocks.dart';

void main() {
  late RoomDetailBloc roomDetailBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    roomDetailBlocMock = getIt<RoomDetailBloc>();
    whenListen(
      roomDetailBlocMock,
      Stream.value(RoomDetailLoaded(room: roomUIMock)),
      initialState: RoomDetailLoaded(room: roomUIMock),
    );
    when(roomDetailBlocMock.close).thenAnswer((_) async {});

    whenListen(
      getIt<RoomMutationBloc>(),
      Stream.value(const RoomMutationState()),
      initialState: const RoomMutationState(),
    );
    when(getIt<RoomMutationBloc>().close).thenAnswer((_) async {});

    whenListen(
      getIt<FacultiesBloc>(),
      Stream.value(FacultiesLoaded(facultiesMock)),
      initialState: FacultiesLoaded(facultiesMock),
    );
    when(getIt<FacultiesBloc>().close).thenAnswer((_) async {});
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function(Room)? onRoomDeleted,
  }) {
    return tester.pumpPageForTest(
      page: RoomDetailPage(
        id: roomMock.id,
        onRoomDeleted: onRoomDeleted,
      ),
    );
  }

  tearDown(() {
    reset(roomDetailBlocMock);
  });

  group('RoomDetailPage', () {
    group('Init', () {
      testWidgets(
        'add RoomDetailSubscriptionRequested event to RoomDetailBloc',
        (tester) async {
          await pumpWidget(tester);

          verify(
            () => roomDetailBlocMock.add(
              RoomDetailSubscriptionRequested(id: roomMock.id),
            ),
          ).called(1);
        },
      );
    });

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Detail Ruangan'), findsOneWidget);
      });

      testWidgets('provides RoomDetailBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<RoomDetailBloc>), findsOneWidget);
      });

      testWidgets('provides RoomMutationBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<RoomMutationBloc>), findsOneWidget);
      });

      testWidgets('provides FacultiesBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<FacultiesBloc>), findsOneWidget);
      });

      testWidgets('shows RoomDetail', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(RoomDetail), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets(
        'add RoomDetailSubscriptionRequested event '
        'when retry button on RoomDetail is pressed',
        (tester) async {
          await pumpWidget(tester);

          final roomDetailFinder = find.byType(RoomDetail);
          expect(roomDetailFinder, findsOneWidget);
          final widget = tester.widget<RoomDetail>(roomDetailFinder);
          widget.onRetryPressed!();

          verify(
            () => roomDetailBlocMock.add(
              RoomDetailSubscriptionRequested(id: roomMock.id),
            ),
          ).called(2);
        },
      );
    });

    group('Side Effects', () {
      testWidgets(
        'calls onRoomDeleted when RoomDetail fires onRoomDeleted',
        (tester) async {
          Room? room;

          await pumpWidget(
            tester,
            onRoomDeleted: (v) {
              room = v;
            },
          );

          final widget = tester.widget<RoomDetail>(
            find.byType(RoomDetail),
          );
          widget.onRoomDeleted!(roomMock);

          expect(room, roomMock);
        },
      );
    });
  });
}
