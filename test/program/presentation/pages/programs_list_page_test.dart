import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late ProgramsBloc programsBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    programsBlocMock = getIt<ProgramsBloc>();
    whenListen(
      programsBlocMock,
      Stream.value(ProgramsLoaded(programsUIMock)),
      initialState: ProgramsLoaded(programsUIMock),
    );
    when(programsBlocMock.close).thenAnswer((_) async {});

    whenListen(
      getIt<ProgramDetailBloc>(),
      Stream.value(const ProgramDetailLoaded(program: programMock)),
      initialState: const ProgramDetailLoaded(program: programMock),
    );
    when(getIt<ProgramDetailBloc>().close).thenAnswer((_) async {});

    whenListen(
      getIt<ProgramMutationBloc>(),
      Stream.value(const ProgramMutationState()),
      initialState: const ProgramMutationState(),
    );
    when(getIt<ProgramMutationBloc>().close).thenAnswer((_) async {});
  });

  tearDown(() {
    reset(programsBlocMock);
    reset(getIt<ProgramDetailBloc>());
    reset(getIt<ProgramMutationBloc>());
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Size? phoneSize,
    void Function(String)? onProgramPressed,
    void Function()? onCreatePressed,
  }) {
    return tester.pumpPageForTest(
      path: '/programs',
      page: ProgramsListPage(
        onProgramPressed: onProgramPressed,
        onCreatePressed: onCreatePressed,
      ),
      phoneSize: phoneSize,
      childRoutes: [
        GoRoute(
          path: 'create',
          builder: (_, _) {
            return const CreateProgramPage();
          },
        ),
        GoRoute(
          path: 'create-compact',
          builder: (_, _) {
            return const CreateProgramPage();
          },
        ),
        GoRoute(
          path: ':id',
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            return ProgramDetailPage(id: id);
          },
        ),
        GoRoute(
          path: 'compact/:id',
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            return ProgramDetailPage(id: id);
          },
        ),
      ],
    );
  }

  group('ProgramsListPage', () {
    Future<void> createButtonPressed(WidgetTester tester) async {
      final widget = tester.widget<ProgramsList>(
        find.byType(ProgramsList),
      );
      widget.onCreatePressed!();
      await tester.pumpAndSettle();
    }

    Future<void> programPressed(WidgetTester tester) async {
      final widget = tester.widget<ProgramsList>(
        find.byType(ProgramsList),
      );
      widget.onPressed!(programMock);
      await tester.pumpAndSettle();
    }

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Daftar Program Studi'), findsOneWidget);
      });

      testWidgets('provides ProgramsBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<ProgramsBloc>), findsOneWidget);
      });

      testWidgets('shows ProgramsList in compact screen', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(450, 800));

        expect(find.byType(ProgramsList), findsOneWidget);
      });

      testWidgets('shows ProgramsList in medium screen', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(650, 800));

        expect(find.byType(ProgramsList), findsOneWidget);
      });

      testWidgets('shows ProgramsList and CreateProgramPage '
          'in expanded screen when create button is pressed', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(850, 800));

        await createButtonPressed(tester);

        expect(find.byType(ProgramsList), findsOneWidget);
        expect(find.byType(CreateProgramPage), findsOneWidget);
      });

      testWidgets('shows ProgramsList and CreateProgramPage '
          'in large screen when create button is pressed', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(1250, 800));

        await createButtonPressed(tester);

        expect(find.byType(ProgramsList), findsOneWidget);
        expect(find.byType(CreateProgramPage), findsOneWidget);
      });

      testWidgets('shows ProgramsList and ProgramDetailPage '
          'in expanded screen when a program is pressed', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(850, 800));

        await programPressed(tester);

        expect(find.byType(ProgramsList), findsOneWidget);
        expect(find.byType(ProgramDetailPage), findsOneWidget);
      });

      testWidgets('shows ProgramsList and ProgramDetailPage '
          'in large screen when a program is pressed', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(1250, 800));

        await programPressed(tester);

        expect(find.byType(ProgramsList), findsOneWidget);
        expect(find.byType(ProgramDetailPage), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets(
        'go to create page when create button is pressed in compact screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(450, 800));

          await createButtonPressed(tester);

          expect(find.byType(ProgramsList), findsNothing);
          expect(find.byType(CreateProgramPage), findsOneWidget);
        },
      );

      testWidgets(
        'go to create page when create button is pressed in medium screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(650, 800));

          await createButtonPressed(tester);

          expect(find.byType(ProgramsList), findsNothing);
          expect(find.byType(CreateProgramPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows create page when create button is pressed in expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(900, 800));

          await createButtonPressed(tester);

          expect(find.byType(ProgramsList), findsOneWidget);
          expect(find.byType(CreateProgramPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows create page when create button is pressed in large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await createButtonPressed(tester);

          expect(find.byType(ProgramsList), findsOneWidget);
          expect(find.byType(CreateProgramPage), findsOneWidget);
        },
      );

      testWidgets(
        'go to detail page when a program is pressed in compact screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(450, 800));

          await programPressed(tester);

          expect(find.byType(ProgramsList), findsNothing);
          expect(find.byType(ProgramDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'go to detail page when a program is pressed in medium screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(650, 800));

          await programPressed(tester);

          expect(find.byType(ProgramsList), findsNothing);
          expect(find.byType(ProgramDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows detail page when a program is pressed in expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(900, 800));

          await programPressed(tester);

          expect(find.byType(ProgramsList), findsOneWidget);
          expect(find.byType(ProgramDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows detail page when a program is pressed in large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await programPressed(tester);

          expect(find.byType(ProgramsList), findsOneWidget);
          expect(find.byType(ProgramDetailPage), findsOneWidget);
        },
      );
    });
  });
}
