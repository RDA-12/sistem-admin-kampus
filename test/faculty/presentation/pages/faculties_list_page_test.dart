import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';

void main() {
  late FacultiesBloc facultiesBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    facultiesBlocMock = getIt<FacultiesBloc>();
    whenListen(
      facultiesBlocMock,
      Stream.value(const FacultiesInitial()),
      initialState: const FacultiesInitial(),
    );
    when(facultiesBlocMock.close).thenAnswer((_) async {});
  });

  tearDown(() {
    reset(facultiesBlocMock);
  });

  Future<void> pumpWidget(WidgetTester tester) {
    return tester.pumpPageForTest(
      path: '/faculties',
      page: const FacultiesListPage(),
      childRoutes: [
        GoRoute(
          path: 'create',
          builder: (_, _) {
            return const SizedBox.shrink(
              key: ValueKey('create-page'),
            );
          },
        ),
      ],
    );
  }

  group('FacultiesListPage', () {
    group('Render', () {
      testWidgets('provides FacultiesBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<FacultiesBloc>), findsOneWidget);
      });

      testWidgets('shows FacultiesList', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(FacultiesList), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets(
        'go to create page when create button pressed',
        (tester) async {
          await pumpWidget(tester);

          final widget = tester.widget<FacultiesList>(
            find.byType(FacultiesList),
          );
          widget.onCreatePressed!();

          await tester.pumpAndSettle();

          expect(find.byKey(const ValueKey('create-page')), findsOneWidget);
        },
      );
    });
  });
}
