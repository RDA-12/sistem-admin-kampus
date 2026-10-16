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

void main() {
  group('CreateRoomPage', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      final roomMutationBlocMock = getIt<RoomMutationBloc>();
      whenListen(
        roomMutationBlocMock,
        Stream.value(const RoomMutationState()),
        initialState: const RoomMutationState(),
      );
      when(roomMutationBlocMock.close).thenAnswer((_) async {});

      final facultiesBlocMock = getIt<FacultiesBloc>();
      whenListen(
        facultiesBlocMock,
        Stream.value(FacultiesLoaded(facultiesMock)),
        initialState: FacultiesLoaded(facultiesMock),
      );
      when(facultiesBlocMock.close).thenAnswer((_) async {});
    });

    Future<void> pumpWidget(WidgetTester tester) {
      return tester.pumpPageForTest(
        page: const CreateRoomPage(),
      );
    }

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Buat Ruangan Baru'), findsOneWidget);
      });

      testWidgets('shows RoomForm', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(RoomForm), findsOneWidget);
      });

      testWidgets(
        'provides BlocProvider<RoomMutationBloc>',
        (tester) async {
          await pumpWidget(tester);

          expect(
            find.byType(BlocProvider<RoomMutationBloc>),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'provides BlocProvider<FacultiesBloc>',
        (tester) async {
          await pumpWidget(tester);

          expect(
            find.byType(BlocProvider<FacultiesBloc>),
            findsOneWidget,
          );
        },
      );
    });
  });
}
