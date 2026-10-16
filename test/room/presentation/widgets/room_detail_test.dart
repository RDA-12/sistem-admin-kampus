import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
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

    whenListen(
      getIt<RoomMutationBloc>(),
      Stream.value(const RoomMutationState()),
      initialState: const RoomMutationState(),
    );

    whenListen(
      getIt<FacultiesBloc>(),
      Stream.value(FacultiesLoaded(facultiesMock)),
      initialState: FacultiesLoaded(facultiesMock),
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function()? onRetryPressed,
    void Function(Room)? onRoomDeleted,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return RoomDetail(
          onRetryPressed: onRetryPressed,
          onRoomDeleted: onRoomDeleted,
        );
      },
      providerBuilder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: roomDetailBlocMock,
            ),
            BlocProvider.value(
              value: getIt<RoomMutationBloc>(),
            ),
            BlocProvider.value(
              value: getIt<FacultiesBloc>(),
            ),
          ],
          child: child,
        );
      },
    );
  }

  group('RoomDetail', () {
    group('Render', () {
      testWidgets(
        'shows RoomForm with correct room '
        'when state is loaded',
        (tester) async {
          await pumpWidget(tester);

          final finder = find.byType(RoomForm);
          expect(finder, findsOneWidget);
          final widget = tester.widget<RoomForm>(finder);
          expect(widget.initial, roomUIMock);
        },
      );

      testWidgets(
        'shows LoadingIndicator when state is loading',
        (tester) async {
          whenListen(
            roomDetailBlocMock,
            Stream.value(const LoadingRoomDetail()),
            initialState: const LoadingRoomDetail(),
          );

          await pumpWidget(tester);

          expect(find.byType(LoadingIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'shows AppExceptionBox when state is failed',
        (tester) async {
          whenListen(
            roomDetailBlocMock,
            Stream.value(
              RoomDetailLoadFailed(exception: AppException.test()),
            ),
            initialState: RoomDetailLoadFailed(
              exception: AppException.test(),
            ),
          );

          await pumpWidget(tester);

          final finder = find.byType(AppExceptionBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppExceptionBox>(finder);
          expect(widget.title, 'Gagal mengambil data ruangan');
          expect(widget.exception, AppException.test());
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'calls onRetryPressed when state is failed '
        'and retry button is pressed',
        (tester) async {
          whenListen(
            roomDetailBlocMock,
            Stream.value(
              RoomDetailLoadFailed(exception: AppException.test()),
            ),
            initialState: RoomDetailLoadFailed(
              exception: AppException.test(),
            ),
          );
          var pressed = false;
          await pumpWidget(
            tester,
            onRetryPressed: () {
              pressed = true;
            },
          );

          await tester.tap(
            find.descendant(
              of: find.byType(AppExceptionBox),
              matching: find.byType(AppButton),
            ),
          );

          expect(pressed, isTrue);
        },
      );
    });

    group('Side Effects', () {
      testWidgets(
        'calls onRoomDeleted '
        'when RoomDetail fires onRoomDeleted callback',
        (tester) async {
          Room? deleted;

          await pumpWidget(
            tester,
            onRoomDeleted: (v) {
              deleted = v;
            },
          );

          final finder = find.byType(RoomForm);
          expect(finder, findsOneWidget);
          final widget = tester.widget<RoomForm>(finder);
          widget.onRoomDeleted!(roomUIMock);

          expect(deleted, roomUIMock);
        },
      );
    });
  });
}
