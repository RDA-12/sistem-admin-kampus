import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../../program/domain/mocks.dart';
import '../../domain/mocks.dart';

void main() {
  late CourseDetailBloc courseDetailBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    courseDetailBlocMock = getIt<CourseDetailBloc>();
    whenListen(
      courseDetailBlocMock,
      Stream.value(CourseDetailLoaded(course: courseUIMock)),
      initialState: CourseDetailLoaded(course: courseUIMock),
    );
    when(courseDetailBlocMock.close).thenAnswer((_) async {});

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

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function(Course)? onCourseDeleted,
  }) {
    return tester.pumpPageForTest(
      page: CourseDetailPage(
        id: courseMock.id,
        onCourseDeleted: onCourseDeleted,
      ),
    );
  }

  tearDown(() {
    reset(courseDetailBlocMock);
  });

  group('CourseDetailPage', () {
    group('Init', () {
      testWidgets(
        'add CourseDetailSubscriptionRequested event to CourseDetailBloc',
        (tester) async {
          await pumpWidget(tester);

          verify(
            () => courseDetailBlocMock.add(
              CourseDetailSubscriptionRequested(id: courseMock.id),
            ),
          ).called(1);
        },
      );
    });

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Detail Mata Kuliah'), findsOneWidget);
      });

      testWidgets('provides CourseDetailBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<CourseDetailBloc>), findsOneWidget);
      });

      testWidgets('provides CourseMutationBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<CourseMutationBloc>), findsOneWidget);
      });

      testWidgets('provides ProgramsBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<ProgramsBloc>), findsOneWidget);
      });

      testWidgets('shows CourseDetail', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(CourseDetail), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets(
        'add CourseDetailSubscriptionRequested event '
        'when retry button on CourseDetail is pressed',
        (tester) async {
          await pumpWidget(tester);

          final courseDetailFinder = find.byType(CourseDetail);
          expect(courseDetailFinder, findsOneWidget);
          final widget = tester.widget<CourseDetail>(courseDetailFinder);
          widget.onRetryPressed!();

          verify(
            () => courseDetailBlocMock.add(
              CourseDetailSubscriptionRequested(id: courseMock.id),
            ),
          ).called(2);
        },
      );
    });

    group('Side Effects', () {
      testWidgets(
        'calls onCourseDeleted when CourseDetail fires onCourseDeleted',
        (tester) async {
          Course? course;

          await pumpWidget(
            tester,
            onCourseDeleted: (v) {
              course = v;
            },
          );

          final widget = tester.widget<CourseDetail>(
            find.byType(CourseDetail),
          );
          widget.onCourseDeleted!(courseMock);

          expect(course, courseMock);
        },
      );
    });
  });
}
