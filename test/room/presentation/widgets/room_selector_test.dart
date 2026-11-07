import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/room/room.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late RoomSelectorController controller;
  late RoomsBloc roomsBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    roomsBlocMock = getIt<RoomsBloc>();
    whenListen(
      roomsBlocMock,
      Stream.value(RoomsLoaded(roomsUIMock)),
      initialState: RoomsLoaded(roomsUIMock),
    );

    controller = RoomSelectorController();
  });

  tearDown(() {
    reset(roomsBlocMock);
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    String? label,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return RoomSelector(
          label: label ?? 'Label',
          controller: controller,
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

  Future<void> openSelector(
    WidgetTester tester, {
    bool pumpOnly = false,
  }) async {
    await tester.tap(find.byType(AppFormField));
    if (pumpOnly) {
      await tester.pump();
    } else {
      await tester.pumpAndSettle();
    }
  }

  group('RoomSelectorController', () {
    test('sets itemAsString to (it) => it.name on initial', () {
      final ctrl = RoomSelectorController(initial: roomsMock.first);

      expect(ctrl.selected, roomsMock.first);
      expect(ctrl.textEditingController.text, roomsMock.first.name);
    });

    test('sets itemAsString to (it) => it.name when selected is changed', () {
      controller.selected = roomsMock.first;

      expect(controller.textEditingController.text, roomsMock.first.name);
    });
  });

  group('RoomSelector', () {
    group('Render', () {
      testWidgets('configures AppSelector correctly', (tester) async {
        await pumpWidget(tester, label: 'Custom Room');

        final appSelectorFinder = find.byType(AppSelector<Room>);
        expect(appSelectorFinder, findsOneWidget);

        final appSelector = tester.widget<AppSelector<Room>>(
          appSelectorFinder,
        );
        expect(appSelector.label, 'Custom Room');
        expect(appSelector.dialogTitle, 'Pilih Ruangan');
        expect(appSelector.controller, controller);
      });

      testWidgets(
        'shows LoadingIndicator on dialog when state is loading',
        (tester) async {
          whenListen(
            roomsBlocMock,
            Stream.value(const LoadingRooms()),
            initialState: const LoadingRooms(),
          );
          await pumpWidget(tester);

          await openSelector(tester, pumpOnly: true);

          expect(find.byType(LoadingIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'shows AppExceptionBox on dialog when state is failed',
        (tester) async {
          whenListen(
            roomsBlocMock,
            Stream.value(RoomsFailure(AppException.test())),
            initialState: RoomsFailure(AppException.test()),
          );
          await pumpWidget(tester);

          await openSelector(tester);

          final finder = find.byType(AppExceptionBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppExceptionBox>(finder);
          expect(widget.exception, AppException.test());
        },
      );

      testWidgets(
        'ensures options showed to users is the name of Room',
        (tester) async {
          await pumpWidget(tester);

          await openSelector(tester);

          for (final r in roomsMock) {
            final finder = find.ancestor(
              of: find.text(r.name),
              matching: find.byType(CheckboxListTile),
            );
            await tester.ensureVisible(finder);
            expect(finder, findsOneWidget);
          }
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'triggers RoomsSubscriptionRequested when selector is pressed',
        (tester) async {
          await pumpWidget(tester);

          await openSelector(tester);

          verify(
            () => roomsBlocMock.add(
              const RoomsSubscriptionRequested(),
            ),
          ).called(1);
        },
      );
    });
  });
}
