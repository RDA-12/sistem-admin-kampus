import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
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

    whenListen(
      getIt<CourseMutationBloc>(),
      Stream.value(const CourseMutationState()),
      initialState: const CourseMutationState(),
    );

    whenListen(
      getIt<ProgramsBloc>(),
      Stream.value(ProgramsLoaded(programsUIMock)),
      initialState: ProgramsLoaded(programsUIMock),
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function()? onRetryPressed,
    void Function(Course)? onCourseDeleted,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return CourseDetail(
          onRetryPressed: onRetryPressed,
          onCourseDeleted: onCourseDeleted,
        );
      },
      providerBuilder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: courseDetailBlocMock,
            ),
            BlocProvider.value(
              value: getIt<CourseMutationBloc>(),
            ),
            BlocProvider.value(
              value: getIt<ProgramsBloc>(),
            ),
          ],
          child: child,
        );
      },
    );
  }

  group('CourseDetail', () {
    group('Render', () {
      testWidgets('shows CourseForm with correct course when state is loaded', (
        tester,
      ) async {
        await pumpWidget(tester);

        final finder = find.byType(CourseForm);
        expect(finder, findsOneWidget);
        final widget = tester.widget<CourseForm>(finder);
        expect(widget.initial, courseUIMock);
      });

      testWidgets('shows LoadingIndicator when state is loading', (
        tester,
      ) async {
        whenListen(
          courseDetailBlocMock,
          Stream.value(const LoadingCourseDetail()),
          initialState: const LoadingCourseDetail(),
        );

        await pumpWidget(tester);

        expect(find.byType(LoadingIndicator), findsOneWidget);
      });

      testWidgets('shows AppExceptionBox when state is failed', (tester) async {
        whenListen(
          courseDetailBlocMock,
          Stream.value(
            CourseDetailLoadFailed(exception: AppException.test()),
          ),
          initialState: CourseDetailLoadFailed(
            exception: AppException.test(),
          ),
        );

        await pumpWidget(tester);

        final finder = find.byType(AppExceptionBox);
        expect(finder, findsOneWidget);
        final widget = tester.widget<AppExceptionBox>(finder);
        expect(widget.title, 'Gagal mengambil data mata kuliah');
        expect(widget.exception, AppException.test());
      });
    });

    group('Interactions', () {
      testWidgets(
        'calls onRetryPressed when state is failed and retry button is pressed',
        (tester) async {
          whenListen(
            courseDetailBlocMock,
            Stream.value(
              CourseDetailLoadFailed(exception: AppException.test()),
            ),
            initialState: CourseDetailLoadFailed(
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
        'calls onCourseDeleted '
        'when CourseDetail fires onCourseDeleted callback',
        (tester) async {
          Course? deleted;

          await pumpWidget(
            tester,
            onCourseDeleted: (v) {
              deleted = v;
            },
          );

          final finder = find.byType(CourseForm);
          expect(finder, findsOneWidget);
          final widget = tester.widget<CourseForm>(finder);
          widget.onCourseDeleted!(courseUIMock);

          expect(deleted, courseUIMock);
        },
      );
    });
  });
}
