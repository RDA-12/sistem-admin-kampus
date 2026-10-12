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
import '../../domain/mocks.dart';

void main() {
  late FacultiesBloc facultiesBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    facultiesBlocMock = getIt<FacultiesBloc>();
    whenListen(
      facultiesBlocMock,
      Stream.value(FacultiesLoaded(facultiesMock)),
      initialState: FacultiesLoaded(facultiesMock),
    );
    when(facultiesBlocMock.close).thenAnswer((_) async {});

    whenListen(
      getIt<FacultyMutationBloc>(),
      Stream.value(const FacultyMutationState()),
      initialState: const FacultyMutationState(),
    );
    when(getIt<FacultyMutationBloc>().close).thenAnswer((_) async {});

    whenListen(
      getIt<FacultyDetailBloc>(),
      Stream.value(const FacultyDetailLoaded(faculty: facultyMock)),
      initialState: const FacultyDetailLoaded(faculty: facultyMock),
    );
    when(getIt<FacultyDetailBloc>().close).thenAnswer((_) async {});
  });

  tearDown(() {
    reset(facultiesBlocMock);
    reset(getIt<FacultyMutationBloc>());
    reset(getIt<FacultyDetailBloc>());
  });

  Future<void> pumpWidget(WidgetTester tester, {Size? phoneSize}) {
    return tester.pumpPageForTest(
      path: '/faculties',
      page: const FacultiesListPage(),
      phoneSize: phoneSize,
      childRoutes: [
        GoRoute(
          path: 'create',
          builder: (_, _) {
            return const CreateFacultyPage();
          },
        ),
        GoRoute(
          path: 'create-compact',
          builder: (_, _) {
            return const CreateFacultyPage();
          },
        ),
        GoRoute(
          path: ':id',
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            return FacultyDetailPage(id: id);
          },
        ),
        GoRoute(
          path: 'compact/:id',
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            return FacultyDetailPage(id: id);
          },
        ),
      ],
    );
  }

  group('FacultiesListPage', () {
    Future<void> createButtonPressed(WidgetTester tester) async {
      final widget = tester.widget<FacultiesList>(
        find.byType(FacultiesList),
      );
      widget.onCreatePressed!();
      await tester.pumpAndSettle();
    }

    Future<void> facultyPressed(WidgetTester tester) async {
      final widget = tester.widget<FacultiesList>(
        find.byType(FacultiesList),
      );
      widget.onPressed!(facultyMock);
      await tester.pumpAndSettle();
    }

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Daftar Fakultas'), findsOneWidget);
      });

      testWidgets('provides FacultiesBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<FacultiesBloc>), findsOneWidget);
      });

      testWidgets('shows FacultiesList in compact screen', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(450, 800));

        expect(find.byType(FacultiesList), findsOneWidget);
      });

      testWidgets('shows FacultiesList in medium screen', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(650, 800));

        expect(find.byType(FacultiesList), findsOneWidget);
      });

      testWidgets('shows FacultiesList and CreateFacultyPage '
          'in expanded screen when create button is pressed', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(850, 800));

        await createButtonPressed(tester);

        expect(find.byType(FacultiesList), findsOneWidget);
        expect(find.byType(CreateFacultyPage), findsOneWidget);
      });

      testWidgets('shows FacultiesList and CreateFacultyPage '
          'in large screen when create button is pressed', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(1250, 800));

        await createButtonPressed(tester);

        expect(find.byType(FacultiesList), findsOneWidget);
        expect(find.byType(CreateFacultyPage), findsOneWidget);
      });

      testWidgets('shows FacultiesList and FacultyDetailPage '
          'in expanded screen when a faculty is pressed', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(850, 800));

        await facultyPressed(tester);

        expect(find.byType(FacultiesList), findsOneWidget);
        expect(find.byType(FacultyDetailPage), findsOneWidget);
      });

      testWidgets('shows FacultiesList and FacultyDetailPage '
          'in large screen when a faculty is pressed', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(1250, 800));

        await facultyPressed(tester);

        expect(find.byType(FacultiesList), findsOneWidget);
        expect(find.byType(FacultyDetailPage), findsOneWidget);
      });

      testWidgets(
        'set selectedId on FacultiesList '
        'when a faculty is pressed in expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(850, 800));

          await facultyPressed(tester);

          final widget = tester.widget<FacultiesList>(
            find.byType(FacultiesList),
          );
          expect(widget.selectedId, facultyMock.id);
        },
      );

      testWidgets(
        'set selectedId on FacultiesList '
        'when a faculty is pressed in large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await facultyPressed(tester);

          final widget = tester.widget<FacultiesList>(
            find.byType(FacultiesList),
          );
          expect(widget.selectedId, facultyMock.id);
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'go to create page when create button is pressed in compact screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(450, 800));

          await createButtonPressed(tester);

          expect(find.byType(FacultiesList), findsNothing);
          expect(find.byType(CreateFacultyPage), findsOneWidget);
        },
      );

      testWidgets(
        'go to create page when create button is pressed in medium screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(650, 800));

          await createButtonPressed(tester);

          expect(find.byType(FacultiesList), findsNothing);
          expect(find.byType(CreateFacultyPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows create page when create button is pressed in expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(900, 800));

          await createButtonPressed(tester);

          expect(find.byType(FacultiesList), findsOneWidget);
          expect(find.byType(CreateFacultyPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows create page when create button is pressed in large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await createButtonPressed(tester);

          expect(find.byType(FacultiesList), findsOneWidget);
          expect(find.byType(CreateFacultyPage), findsOneWidget);
        },
      );

      testWidgets(
        'go to detail page when a faculty is pressed in compact screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(450, 800));

          await facultyPressed(tester);

          expect(find.byType(FacultiesList), findsNothing);
          expect(find.byType(FacultyDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'go to detail page when a faculty is pressed in medium screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(650, 800));

          await facultyPressed(tester);

          expect(find.byType(FacultiesList), findsNothing);
          expect(find.byType(FacultyDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows detail page when a faculty is pressed in expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(900, 800));

          await facultyPressed(tester);

          expect(find.byType(FacultiesList), findsOneWidget);
          expect(find.byType(FacultyDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows detail page when a faculty is pressed in large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await facultyPressed(tester);

          expect(find.byType(FacultiesList), findsOneWidget);
          expect(find.byType(FacultyDetailPage), findsOneWidget);
        },
      );
    });

    group('Side Effects', () {
      testWidgets(
        'hides FacultyDetail page when it fires onFacultyDeleted '
        'in expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(850, 800));

          await facultyPressed(tester);

          final facultyDetailPageFinder = find.byType(FacultyDetailPage);
          expect(facultyDetailPageFinder, findsOneWidget);

          final widget = tester.widget<FacultyDetailPage>(
            facultyDetailPageFinder,
          );
          widget.onFacultyDeleted!(facultyMock);
          await tester.pumpAndSettle();

          expect(facultyDetailPageFinder, findsNothing);
        },
      );

      testWidgets(
        'hides FacultyDetail page when it fires onFacultyDeleted '
        'in large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await facultyPressed(tester);

          final facultyDetailPageFinder = find.byType(FacultyDetailPage);
          expect(facultyDetailPageFinder, findsOneWidget);

          final widget = tester.widget<FacultyDetailPage>(
            facultyDetailPageFinder,
          );
          widget.onFacultyDeleted!(facultyMock);
          await tester.pumpAndSettle();

          expect(facultyDetailPageFinder, findsNothing);
        },
      );
    });
  });
}
