import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../program/domain/mocks.dart';

void main() {
  final courses = List.generate(
    5,
    (index) => CourseUI(
      id: '$index',
      programId: programMock.id,
      code: 'CS10$index',
      name: 'Course $index',
      semester: index + 1,
      credit: 3,
      program: programMock,
    ),
  );

  group('CoursesBloc', () {
    late WatchProgramsUseCase watchProgramsMock;
    late WatchCoursesUseCase watchCoursesMock;

    setUpAll(initializeMockDependencies);

    setUp(() {
      watchCoursesMock = getIt<WatchCoursesUseCase>();
      when(() => watchCoursesMock()).thenAnswer(
        (_) => Stream.value(
          AppResult.success([
            ...courses,
            const Course(
              id: 'id',
              programId: 'programId',
              code: 'CS999',
              name: 'name',
              semester: 1,
              credit: 2,
            ),
          ]),
        ),
      );

      watchProgramsMock = getIt<WatchProgramsUseCase>();
      when(() => watchProgramsMock())
          .thenAnswer((_) => Stream.value(AppResult.success([programMock])));
    });

    CoursesBloc buildBloc() {
      return CoursesBloc(
        watchCourses: watchCoursesMock,
        watchPrograms: watchProgramsMock,
      );
    }

    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const CoursesInitial());
    });

    group('CoursesSubscriptionRequested', () {
      blocTest<CoursesBloc, CoursesState>(
        'emits [LoadingCourses, CoursesLoaded] '
        'when CoursesSubscriptionRequested is added '
        'and WatchCoursesUseCase and WatchProgramsUseCase emits success',
        build: buildBloc,
        act: (bloc) => bloc.add(const CoursesSubscriptionRequested()),
        expect: () => <CoursesState>[
          const LoadingCourses(),
          CoursesLoaded(courses),
        ],
        verify: (_) {
          verify(() => watchCoursesMock()).called(1);
        },
      );

      blocTest<CoursesBloc, CoursesState>(
        'emits [LoadingCourses, CoursesFailure] '
        'when CoursesSubscriptionRequested is added '
        'and WatchProgramsUseCase emits failure',
        setUp: () {
          when(() => watchProgramsMock()).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const CoursesSubscriptionRequested()),
        expect: () => <CoursesState>[
          const LoadingCourses(),
          CoursesFailure(AppException.test()),
        ],
      );

      blocTest<CoursesBloc, CoursesState>(
        'emits [LoadingCourses, CoursesFailure] '
        'when CoursesSubscriptionRequested is added '
        'and WatchCoursesUseCase emits failure',
        setUp: () {
          when(() => watchCoursesMock()).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const CoursesSubscriptionRequested()),
        expect: () => <CoursesState>[
          const LoadingCourses(),
          CoursesFailure(AppException.test()),
        ],
      );
    });
  });
}
