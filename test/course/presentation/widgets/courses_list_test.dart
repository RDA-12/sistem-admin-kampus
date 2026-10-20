import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/course.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late CoursesBloc coursesBlocMock;

  group('CoursesList', () {
    final createButtonFinder = find.ancestor(
      of: find.text('Buat baru'),
      matching: find.byType(AppButton),
    );

    setUpAll(initializeMockDependencies);

    setUp(() {
      coursesBlocMock = getIt<CoursesBloc>();
      whenListen(
        coursesBlocMock,
        Stream.value(CoursesLoaded(coursesUIMock)),
        initialState: CoursesLoaded(coursesUIMock),
      );
    });

    Future<void> pumpWidget(
      WidgetTester tester, {
      void Function(Course)? onPressed,
      void Function()? onCreatePressed,
      String? selectedId,
    }) {
      return tester.pumpWidgetForTest(
        (context) {
          return CoursesList(
            selectedId: selectedId,
            onPressed: onPressed,
            onCreatePressed: onCreatePressed,
          );
        },
        providerBuilder: (context, child) {
          return BlocProvider.value(
            value: coursesBlocMock,
            child: child,
          );
        },
      );
    }

    tearDown(() {
      reset(coursesBlocMock);
    });

    group('Render', () {
      testWidgets('shows all courses when state is loaded', (tester) async {
        await pumpWidget(tester);

        for (final course in coursesUIMock) {
          final courseFinder = find.ancestor(
            of: find.text(course.name),
            matching: find.byType(CourseListTile),
          );
          await tester.ensureVisible(courseFinder);
          await tester.pumpAndSettle();
        }
      });

      testWidgets(
        'shows AppEmptyBox when state is loaded with empty data',
        (tester) async {
          whenListen(
            coursesBlocMock,
            Stream.value(const CoursesLoaded([])),
            initialState: const CoursesLoaded([]),
          );

          await pumpWidget(tester);

          final finder = find.byType(AppEmptyBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppEmptyBox>(finder);
          expect(widget.message, 'Belum ada data mata kuliah');
        },
      );

      testWidgets('shows LoadingIndicator when state is loading/initial', (
        tester,
      ) async {
        final controller = StreamController<CoursesState>.broadcast();
        when(() => coursesBlocMock.stream).thenAnswer((_) => controller.stream);

        await pumpWidget(tester);
        controller.add(const CoursesInitial());
        await tester.pump();

        expect(find.byType(LoadingIndicator), findsOneWidget);

        controller.add(const LoadingCourses());
        await tester.pump();

        expect(find.byType(LoadingIndicator), findsOneWidget);
      });

      testWidgets('shows AppExceptionBox when state is failure', (
        tester,
      ) async {
        whenListen(
          coursesBlocMock,
          Stream.value(CoursesFailure(AppException.test())),
          initialState: CoursesFailure(AppException.test()),
        );

        await pumpWidget(tester);
        await tester.pumpAndSettle();

        final finder = find.byType(AppExceptionBox);
        expect(finder, findsOneWidget);
        final widget = tester.widget<AppExceptionBox>(finder);
        expect(widget.exception, AppException.test());
        expect(widget.title, 'Gagal mengambil data mata kuliah');
      });

      testWidgets('shows create button', (tester) async {
        await pumpWidget(tester);

        expect(createButtonFinder, findsOneWidget);
      });

      testWidgets('shows selected CourseListTile', (tester) async {
        await pumpWidget(tester, selectedId: coursesUIMock.first.id);

        for (final course in coursesUIMock) {
          final finder = find.ancestor(
            of: find.text(course.name),
            matching: find.byType(CourseListTile),
          );
          await tester.ensureVisible(finder);
          final widget = tester.widget<CourseListTile>(finder);
          expect(widget.selected, course.id == coursesUIMock.first.id);
        }
      });
    });

    group('Interactions', () {
      testWidgets(
        'calls onPressed with correct data '
        'when one of courses is pressed',
        (tester) async {
          Course? pressedCourse;
          await pumpWidget(
            tester,
            onPressed: (v) {
              pressedCourse = v;
            },
          );

          final courseFinder = find.text(coursesUIMock.first.name);
          await tester.ensureVisible(courseFinder);
          await tester.pumpAndSettle();
          await tester.tap(courseFinder);

          expect(pressedCourse, coursesUIMock.first);
        },
      );

      testWidgets('calls onCreatePressed when create button is pressed', (
        tester,
      ) async {
        var pressed = false;
        await pumpWidget(
          tester,
          onCreatePressed: () {
            pressed = true;
          },
        );

        await tester.tap(createButtonFinder);

        expect(pressed, isTrue);
      });
    });
  });
}
