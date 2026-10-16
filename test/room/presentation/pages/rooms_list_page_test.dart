import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/room/room.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../../faculty/domain/mocks.dart';
import '../../domain/mocks.dart';

void main() {
  late RoomsBloc roomsBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    roomsBlocMock = getIt<RoomsBloc>();
    whenListen(
      roomsBlocMock,
      Stream.value(RoomsLoaded(roomsUIMock)),
      initialState: RoomsLoaded(roomsUIMock),
    );
    when(roomsBlocMock.close).thenAnswer((_) async {});

    whenListen(
      getIt<RoomDetailBloc>(),
      Stream.value(RoomDetailLoaded(room: roomUIMock)),
      initialState: RoomDetailLoaded(room: roomUIMock),
    );
    when(getIt<RoomDetailBloc>().close).thenAnswer((_) async {});

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

  tearDown(() {
    reset(roomsBlocMock);
    reset(getIt<RoomDetailBloc>());
    reset(getIt<RoomMutationBloc>());
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Size? phoneSize,
    void Function(String)? onRoomPressed,
    void Function()? onCreatePressed,
  }) {
    return tester.pumpPageForTest(
      path: '/rooms',
      page: RoomsListPage(
        onRoomPressed: onRoomPressed,
        onCreatePressed: onCreatePressed,
      ),
      phoneSize: phoneSize,
      childRoutes: [
        GoRoute(
          path: 'create',
          builder: (_, _) {
            return const CreateRoomPage();
          },
        ),
        GoRoute(
          path: 'create-compact',
          builder: (_, _) {
            return const CreateRoomPage();
          },
        ),
        GoRoute(
          path: ':id',
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            return RoomDetailPage(id: id);
          },
        ),
        GoRoute(
          path: 'compact/:id',
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            return RoomDetailPage(id: id);
          },
        ),
      ],
    );
  }

  group('RoomsListPage', () {
    Future<void> createButtonPressed(WidgetTester tester) async {
      final widget = tester.widget<RoomsList>(
        find.byType(RoomsList),
      );
      widget.onCreatePressed!();
      await tester.pumpAndSettle();
    }

    Future<void> roomPressed(WidgetTester tester) async {
      final widget = tester.widget<RoomsList>(
        find.byType(RoomsList),
      );
      widget.onPressed!(roomUIMock);
      await tester.pumpAndSettle();
    }

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Daftar Ruangan'), findsOneWidget);
      });

      testWidgets('provides RoomsBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<RoomsBloc>), findsOneWidget);
      });

      testWidgets('shows RoomsList in compact screen', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(450, 800));

        expect(find.byType(RoomsList), findsOneWidget);
      });

      testWidgets('shows RoomsList in medium screen', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(650, 800));

        expect(find.byType(RoomsList), findsOneWidget);
      });

      testWidgets(
        'shows RoomsList and CreateRoomPage '
        'in expanded screen when create button is pressed',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(850, 800));

          await createButtonPressed(tester);

          expect(find.byType(RoomsList), findsOneWidget);
          expect(find.byType(CreateRoomPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows RoomsList and CreateRoomPage '
        'in large screen when create button is pressed',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await createButtonPressed(tester);

          expect(find.byType(RoomsList), findsOneWidget);
          expect(find.byType(CreateRoomPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows RoomsList and RoomDetailPage '
        'in expanded screen when a room is pressed',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(850, 800));

          await roomPressed(tester);

          expect(find.byType(RoomsList), findsOneWidget);
          expect(find.byType(RoomDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows RoomsList and RoomDetailPage '
        'in large screen when a room is pressed',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await roomPressed(tester);

          expect(find.byType(RoomsList), findsOneWidget);
          expect(find.byType(RoomDetailPage), findsOneWidget);
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'go to create page when create button is pressed in compact screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(450, 800));

          await createButtonPressed(tester);

          expect(find.byType(RoomsList), findsNothing);
          expect(find.byType(CreateRoomPage), findsOneWidget);
        },
      );

      testWidgets(
        'go to create page when create button is pressed in medium screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(650, 800));

          await createButtonPressed(tester);

          expect(find.byType(RoomsList), findsNothing);
          expect(find.byType(CreateRoomPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows create page when create button is pressed in expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(900, 800));

          await createButtonPressed(tester);

          expect(find.byType(RoomsList), findsOneWidget);
          expect(find.byType(CreateRoomPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows create page when create button is pressed in large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await createButtonPressed(tester);

          expect(find.byType(RoomsList), findsOneWidget);
          expect(find.byType(CreateRoomPage), findsOneWidget);
        },
      );

      testWidgets(
        'go to detail page when a room is pressed in compact screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(450, 800));

          await roomPressed(tester);

          expect(find.byType(RoomsList), findsNothing);
          expect(find.byType(RoomDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'go to detail page when a room is pressed in medium screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(650, 800));

          await roomPressed(tester);

          expect(find.byType(RoomsList), findsNothing);
          expect(find.byType(RoomDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows detail page when a room is pressed in expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(900, 800));

          await roomPressed(tester);

          expect(find.byType(RoomsList), findsOneWidget);
          expect(find.byType(RoomDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows detail page when a room is pressed in large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await roomPressed(tester);

          expect(find.byType(RoomsList), findsOneWidget);
          expect(find.byType(RoomDetailPage), findsOneWidget);
        },
      );
    });
  });
}
