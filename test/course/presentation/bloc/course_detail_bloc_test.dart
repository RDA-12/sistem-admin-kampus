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
  final course = Course(
    id: 'id',
    programId: programsMock.first.id,
    code: 'CS101',
    name: 'name',
    semester: 1,
    credit: 3,
  );
  final courseUI = CourseUI(
    id: course.id,
    programId: course.programId,
    code: course.code,
    name: course.name,
    semester: course.semester,
    credit: course.credit,
    program: programsMock.first,
  );
  late WatchSingleCourseUseCase watchSingleCourseMock;
  late WatchProgramsUseCase watchProgramsMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    watchSingleCourseMock = getIt<WatchSingleCourseUseCase>();
    when(() => watchSingleCourseMock(course.id))
        .thenAnswer((_) => Stream.value(AppResult.success(course)));

    watchProgramsMock = getIt<WatchProgramsUseCase>();
    when(() => watchProgramsMock())
        .thenAnswer((_) => Stream.value(AppResult.success(programsMock)));
  });

  tearDown(() {
    reset(watchSingleCourseMock);
    reset(watchProgramsMock);
  });

  CourseDetailBloc buildBloc() {
    return CourseDetailBloc(
      watchSingleCourse: watchSingleCourseMock,
      watchPrograms: watchProgramsMock,
    );
  }

  group('CourseDetailBloc', () {
    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const CourseDetailInitial());
    });

    group('CourseDetailSubscriptionRequested', () {
      blocTest<CourseDetailBloc, CourseDetailState>(
        'emits [LoadingCourseDetail, CourseDetailLoaded] '
        'when CourseDetailSubscriptionRequested is added and '
        'WatchSingleCourseUseCase and WatchProgramsUseCase emits success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseDetailSubscriptionRequested(id: course.id),
        ),
        expect: () => <CourseDetailState>[
          const LoadingCourseDetail(),
          CourseDetailLoaded(course: courseUI),
        ],
        verify: (_) {
          verify(() => watchSingleCourseMock(course.id)).called(1);
          verify(() => watchProgramsMock()).called(1);
        },
      );

      blocTest<CourseDetailBloc, CourseDetailState>(
        'emits [LoadingCourseDetail, CourseDetailLoadFailed] '
        'when CourseDetailSubscriptionRequested is added and '
        'WatchSingleCourseUseCase emits failure',
        setUp: () {
          when(() => watchSingleCourseMock(course.id)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseDetailSubscriptionRequested(id: course.id),
        ),
        expect: () => <CourseDetailState>[
          const LoadingCourseDetail(),
          CourseDetailLoadFailed(exception: AppException.test()),
        ],
        verify: (_) {
          verify(() => watchSingleCourseMock(course.id)).called(1);
        },
      );

      blocTest<CourseDetailBloc, CourseDetailState>(
        'emits [LoadingCourseDetail, CourseDetailLoadFailed] '
        'when CourseDetailSubscriptionRequested is added and '
        'WatchProgramsUseCase emits failure',
        setUp: () {
          when(() => watchProgramsMock()).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseDetailSubscriptionRequested(id: course.id),
        ),
        expect: () => <CourseDetailState>[
          const LoadingCourseDetail(),
          CourseDetailLoadFailed(exception: AppException.test()),
        ],
        verify: (_) {
          verify(() => watchSingleCourseMock(course.id)).called(1);
          verify(() => watchProgramsMock()).called(1);
        },
      );
    });
  });
}
