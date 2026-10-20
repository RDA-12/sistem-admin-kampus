import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/room/room.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late RoomsBloc roomsBlocMock;

  group('RoomsList', () {
    final createButtonFinder = find.ancestor(
      of: find.text('Buat baru'),
      matching: find.byType(AppButton),
    );

    setUpAll(initializeMockDependencies);

    setUp(() {
      roomsBlocMock = getIt<RoomsBloc>();
      whenListen(
        roomsBlocMock,
        Stream.value(RoomsLoaded(roomsUIMock)),
        initialState: RoomsLoaded(roomsUIMock),
      );
    });

    Future<void> pumpWidget(
      WidgetTester tester, {
      void Function(Room)? onPressed,
      void Function()? onCreatePressed,
      String? selectedId,
    }) {
      return tester.pumpWidgetForTest(
        (context) {
          return RoomsList(
            selectedId: selectedId,
            onPressed: onPressed,
            onCreatePressed: onCreatePressed,
          );
        },
        providerBuilder: (context, child) {
          return BlocProvider.value(
            value: roomsBlocMock,
            child: child,
          );
        },
      );
    }

    tearDown(() {
      reset(roomsBlocMock);
    });

    group('Render', () {
      testWidgets('shows all rooms when state is loaded', (tester) async {
        await pumpWidget(tester);

        for (final room in roomsUIMock) {
          final roomFinder = find.ancestor(
            of: find.text(room.name),
            matching: find.byType(RoomListTile),
          );
          await tester.ensureVisible(roomFinder);
          await tester.pumpAndSettle();
        }
      });

      testWidgets(
        'shows AppEmptyBox when state is loaded with empty data',
        (tester) async {
          whenListen(
            roomsBlocMock,
            Stream.value(const RoomsLoaded([])),
            initialState: const RoomsLoaded([]),
          );

          await pumpWidget(tester);

          final finder = find.byType(AppEmptyBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppEmptyBox>(finder);
          expect(widget.message, 'Belum ada data ruangan');
        },
      );

      testWidgets('shows LoadingIndicator when state is loading/initial', (
        tester,
      ) async {
        final controller = StreamController<RoomsState>.broadcast();
        when(() => roomsBlocMock.stream).thenAnswer((_) => controller.stream);

        await pumpWidget(tester);
        controller.add(const RoomsInitial());
        await tester.pump();

        expect(find.byType(LoadingIndicator), findsOneWidget);

        controller.add(const LoadingRooms());
        await tester.pump();

        expect(find.byType(LoadingIndicator), findsOneWidget);
      });

      testWidgets(
        'shows AppExceptionBox when state is failure',
        (tester) async {
          whenListen(
            roomsBlocMock,
            Stream.value(RoomsFailure(AppException.test())),
            initialState: RoomsFailure(AppException.test()),
          );

          await pumpWidget(tester);
          await tester.pumpAndSettle();

          final finder = find.byType(AppExceptionBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppExceptionBox>(finder);
          expect(widget.exception, AppException.test());
          expect(widget.title, 'Gagal mengambil data ruangan');
        },
      );

      testWidgets('shows create button', (tester) async {
        await pumpWidget(tester);

        expect(createButtonFinder, findsOneWidget);
      });

      testWidgets('shows selected RoomListTile', (tester) async {
        await pumpWidget(tester, selectedId: roomsUIMock.first.id);

        for (final room in roomsUIMock) {
          final finder = find.ancestor(
            of: find.text(room.name),
            matching: find.byType(RoomListTile),
          );
          await tester.ensureVisible(finder);
          final widget = tester.widget<RoomListTile>(finder);
          expect(widget.selected, room.id == roomsUIMock.first.id);
        }
      });
    });

    group('Interactions', () {
      testWidgets(
        'calls onPressed with correct data '
        'when one of rooms is pressed',
        (tester) async {
          Room? pressedRoom;
          await pumpWidget(
            tester,
            onPressed: (v) {
              pressedRoom = v;
            },
          );

          final roomFinder = find.text(roomsUIMock.first.name);
          await tester.ensureVisible(roomFinder);
          await tester.pumpAndSettle();
          await tester.tap(roomFinder);

          expect(pressedRoom, roomsUIMock.first);
        },
      );

      testWidgets(
        'calls onCreatePressed when create button is pressed',
        (tester) async {
          var pressed = false;
          await pumpWidget(
            tester,
            onCreatePressed: () {
              pressed = true;
            },
          );

          await tester.tap(createButtonFinder);

          expect(pressed, isTrue);
        },
      );
    });
  });
}
