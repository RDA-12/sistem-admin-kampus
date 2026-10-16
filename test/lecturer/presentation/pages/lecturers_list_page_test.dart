import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../../program/domain/mocks.dart';
import '../../domain/mocks.dart';

void main() {
  late LecturersBloc lecturersBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    lecturersBlocMock = getIt<LecturersBloc>();
    whenListen(
      lecturersBlocMock,
      Stream.value(LecturersLoaded(lecturersUIMock)),
      initialState: LecturersLoaded(lecturersUIMock),
    );
    when(lecturersBlocMock.close).thenAnswer((_) async {});

    whenListen(
      getIt<LecturerDetailBloc>(),
      Stream.value(LecturerDetailLoaded(lecturer: lecturerUIMock)),
      initialState: LecturerDetailLoaded(lecturer: lecturerUIMock),
    );
    when(getIt<LecturerDetailBloc>().close).thenAnswer((_) async {});

    whenListen(
      getIt<LecturerMutationBloc>(),
      Stream.value(const LecturerMutationState()),
      initialState: const LecturerMutationState(),
    );
    when(getIt<LecturerMutationBloc>().close).thenAnswer((_) async {});

    whenListen(
      getIt<ProgramsBloc>(),
      Stream.value(ProgramsLoaded(programsUIMock)),
      initialState: ProgramsLoaded(programsUIMock),
    );
    when(getIt<ProgramsBloc>().close).thenAnswer((_) async {});
  });

  tearDown(() {
    reset(lecturersBlocMock);
    reset(getIt<LecturerDetailBloc>());
    reset(getIt<LecturerMutationBloc>());
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Size? phoneSize,
    void Function(String)? onLecturerPressed,
    void Function()? onCreatePressed,
  }) {
    return tester.pumpPageForTest(
      path: '/lecturers',
      page: LecturersListPage(
        onLecturerPressed: onLecturerPressed,
        onCreatePressed: onCreatePressed,
      ),
      phoneSize: phoneSize,
      childRoutes: [
        GoRoute(
          path: 'create',
          builder: (_, _) {
            return const CreateLecturerPage();
          },
        ),
        GoRoute(
          path: 'create-compact',
          builder: (_, _) {
            return const CreateLecturerPage();
          },
        ),
        GoRoute(
          path: ':id',
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            return LecturerDetailPage(id: id);
          },
        ),
        GoRoute(
          path: 'compact/:id',
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            return LecturerDetailPage(id: id);
          },
        ),
      ],
    );
  }

  group('LecturersListPage', () {
    Future<void> createButtonPressed(WidgetTester tester) async {
      final widget = tester.widget<LecturersList>(
        find.byType(LecturersList),
      );
      widget.onCreatePressed!();
      await tester.pumpAndSettle();
    }

    Future<void> lecturerPressed(WidgetTester tester) async {
      final widget = tester.widget<LecturersList>(
        find.byType(LecturersList),
      );
      widget.onPressed!(lecturerUIMock);
      await tester.pumpAndSettle();
    }

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Daftar Dosen'), findsOneWidget);
      });

      testWidgets('provides LecturersBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<LecturersBloc>), findsOneWidget);
      });

      testWidgets('shows LecturersList in compact screen', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(450, 800));

        expect(find.byType(LecturersList), findsOneWidget);
      });

      testWidgets('shows LecturersList in medium screen', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(650, 800));

        expect(find.byType(LecturersList), findsOneWidget);
      });

      testWidgets('shows LecturersList and CreateLecturerPage '
          'in expanded screen when create button is pressed', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(850, 800));

        await createButtonPressed(tester);

        expect(find.byType(LecturersList), findsOneWidget);
        expect(find.byType(CreateLecturerPage), findsOneWidget);
      });

      testWidgets('shows LecturersList and CreateLecturerPage '
          'in large screen when create button is pressed', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(1250, 800));

        await createButtonPressed(tester);

        expect(find.byType(LecturersList), findsOneWidget);
        expect(find.byType(CreateLecturerPage), findsOneWidget);
      });

      testWidgets('shows LecturersList and LecturerDetailPage '
          'in expanded screen when a lecturer is pressed', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(850, 800));

        await lecturerPressed(tester);

        expect(find.byType(LecturersList), findsOneWidget);
        expect(find.byType(LecturerDetailPage), findsOneWidget);
      });

      testWidgets('shows LecturersList and LecturerDetailPage '
          'in large screen when a lecturer is pressed', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(1250, 800));

        await lecturerPressed(tester);

        expect(find.byType(LecturersList), findsOneWidget);
        expect(find.byType(LecturerDetailPage), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets(
        'go to create page when create button is pressed in compact screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(450, 800));

          await createButtonPressed(tester);

          expect(find.byType(LecturersList), findsNothing);
          expect(find.byType(CreateLecturerPage), findsOneWidget);
        },
      );

      testWidgets(
        'go to create page when create button is pressed in medium screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(650, 800));

          await createButtonPressed(tester);

          expect(find.byType(LecturersList), findsNothing);
          expect(find.byType(CreateLecturerPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows create page when create button is pressed in expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(900, 800));

          await createButtonPressed(tester);

          expect(find.byType(LecturersList), findsOneWidget);
          expect(find.byType(CreateLecturerPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows create page when create button is pressed in large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await createButtonPressed(tester);

          expect(find.byType(LecturersList), findsOneWidget);
          expect(find.byType(CreateLecturerPage), findsOneWidget);
        },
      );

      testWidgets(
        'go to detail page when a lecturer is pressed in compact screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(450, 800));

          await lecturerPressed(tester);

          expect(find.byType(LecturersList), findsNothing);
          expect(find.byType(LecturerDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'go to detail page when a lecturer is pressed in medium screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(650, 800));

          await lecturerPressed(tester);

          expect(find.byType(LecturersList), findsNothing);
          expect(find.byType(LecturerDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows detail page when a lecturer is pressed in expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(900, 800));

          await lecturerPressed(tester);

          expect(find.byType(LecturersList), findsOneWidget);
          expect(find.byType(LecturerDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows detail page when a lecturer is pressed in large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await lecturerPressed(tester);

          expect(find.byType(LecturersList), findsOneWidget);
          expect(find.byType(LecturerDetailPage), findsOneWidget);
        },
      );
    });
  });
}
