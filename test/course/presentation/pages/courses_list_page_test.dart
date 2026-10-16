import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../../program/domain/mocks.dart';
import '../../domain/mocks.dart';

void main() {
  late CoursesBloc coursesBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    coursesBlocMock = getIt<CoursesBloc>();
    whenListen(
      coursesBlocMock,
      Stream.value(CoursesLoaded(coursesUIMock)),
      initialState: CoursesLoaded(coursesUIMock),
    );
    when(coursesBlocMock.close).thenAnswer((_) async {});

    whenListen(
      getIt<CourseDetailBloc>(),
      Stream.value(CourseDetailLoaded(course: courseUIMock)),
      initialState: CourseDetailLoaded(course: courseUIMock),
    );
    when(getIt<CourseDetailBloc>().close).thenAnswer((_) async {});

    whenListen(
      getIt<CourseMutationBloc>(),
      Stream.value(const CourseMutationState()),
      initialState: const CourseMutationState(),
    );
    when(getIt<CourseMutationBloc>().close).thenAnswer((_) async {});

    whenListen(
      getIt<ProgramsBloc>(),
      Stream.value(ProgramsLoaded(programsUIMock)),
      initialState: ProgramsLoaded(programsUIMock),
    );
    when(getIt<ProgramsBloc>().close).thenAnswer((_) async {});
  });

  tearDown(() {
    reset(coursesBlocMock);
    reset(getIt<CourseDetailBloc>());
    reset(getIt<CourseMutationBloc>());
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Size? phoneSize,
    void Function(String)? onCoursePressed,
    void Function()? onCreatePressed,
  }) {
    return tester.pumpPageForTest(
      path: '/courses',
      page: CoursesListPage(
        onCoursePressed: onCoursePressed,
        onCreatePressed: onCreatePressed,
      ),
      phoneSize: phoneSize,
      childRoutes: [
        GoRoute(
          path: 'create',
          builder: (_, _) {
            return const CreateCoursePage();
          },
        ),
        GoRoute(
          path: 'create-compact',
          builder: (_, _) {
            return const CreateCoursePage();
          },
        ),
        GoRoute(
          path: ':id',
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            return CourseDetailPage(id: id);
          },
        ),
        GoRoute(
          path: 'compact/:id',
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            return CourseDetailPage(id: id);
          },
        ),
      ],
    );
  }

  group('CoursesListPage', () {
    Future<void> createButtonPressed(WidgetTester tester) async {
      final widget = tester.widget<CoursesList>(
        find.byType(CoursesList),
      );
      widget.onCreatePressed!();
      await tester.pumpAndSettle();
    }

    Future<void> coursePressed(WidgetTester tester) async {
      final widget = tester.widget<CoursesList>(
        find.byType(CoursesList),
      );
      widget.onPressed!(courseUIMock);
      await tester.pumpAndSettle();
    }

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Daftar Mata Kuliah'), findsOneWidget);
      });

      testWidgets('provides CoursesBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<CoursesBloc>), findsOneWidget);
      });

      testWidgets('shows CoursesList in compact screen', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(450, 800));

        expect(find.byType(CoursesList), findsOneWidget);
      });

      testWidgets('shows CoursesList in medium screen', (tester) async {
        await pumpWidget(tester, phoneSize: const Size(650, 800));

        expect(find.byType(CoursesList), findsOneWidget);
      });

      testWidgets(
        'shows CoursesList and CreateCoursePage '
        'in expanded screen when create button is pressed',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(850, 800));

          await createButtonPressed(tester);

          expect(find.byType(CoursesList), findsOneWidget);
          expect(find.byType(CreateCoursePage), findsOneWidget);
        },
      );

      testWidgets(
        'shows CoursesList and CreateCoursePage '
        'in large screen when create button is pressed',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await createButtonPressed(tester);

          expect(find.byType(CoursesList), findsOneWidget);
          expect(find.byType(CreateCoursePage), findsOneWidget);
        },
      );

      testWidgets(
        'shows CoursesList and CourseDetailPage '
        'in expanded screen when a course is pressed',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(850, 800));

          await coursePressed(tester);

          expect(find.byType(CoursesList), findsOneWidget);
          expect(find.byType(CourseDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows CoursesList and CourseDetailPage '
        'in large screen when a course is pressed',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await coursePressed(tester);

          expect(find.byType(CoursesList), findsOneWidget);
          expect(find.byType(CourseDetailPage), findsOneWidget);
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'go to create page when create button is pressed in compact screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(450, 800));

          await createButtonPressed(tester);

          expect(find.byType(CoursesList), findsNothing);
          expect(find.byType(CreateCoursePage), findsOneWidget);
        },
      );

      testWidgets(
        'go to create page when create button is pressed in medium screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(650, 800));

          await createButtonPressed(tester);

          expect(find.byType(CoursesList), findsNothing);
          expect(find.byType(CreateCoursePage), findsOneWidget);
        },
      );

      testWidgets(
        'shows create page when create button is pressed in expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(900, 800));

          await createButtonPressed(tester);

          expect(find.byType(CoursesList), findsOneWidget);
          expect(find.byType(CreateCoursePage), findsOneWidget);
        },
      );

      testWidgets(
        'shows create page when create button is pressed in large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await createButtonPressed(tester);

          expect(find.byType(CoursesList), findsOneWidget);
          expect(find.byType(CreateCoursePage), findsOneWidget);
        },
      );

      testWidgets(
        'go to detail page when a course is pressed in compact screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(450, 800));

          await coursePressed(tester);

          expect(find.byType(CoursesList), findsNothing);
          expect(find.byType(CourseDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'go to detail page when a course is pressed in medium screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(650, 800));

          await coursePressed(tester);

          expect(find.byType(CoursesList), findsNothing);
          expect(find.byType(CourseDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows detail page when a course is pressed in expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(900, 800));

          await coursePressed(tester);

          expect(find.byType(CoursesList), findsOneWidget);
          expect(find.byType(CourseDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows detail page when a course is pressed in large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await coursePressed(tester);

          expect(find.byType(CoursesList), findsOneWidget);
          expect(find.byType(CourseDetailPage), findsOneWidget);
        },
      );
    });
  });
}
