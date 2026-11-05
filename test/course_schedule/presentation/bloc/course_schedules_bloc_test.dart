import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';
import 'package:sistem_admin/room/room.dart';

import '../../../academic_calendar/domain/mocks.dart';
import '../../../cohort/domain/mocks.dart';
import '../../../common/di_mocks.dart';
import '../../../course/domain/mocks.dart';
import '../../../lecturer/domain/mocks.dart';
import '../../../room/domain/mocks.dart';

void main() {
  final testYear = academicYearMock;
  const testTermId = 'term_1';
  const testProgramId = 'program_1';

  final testSchedules = List.generate(
    3,
    (index) => CourseSchedule(
      id: '$index',
      academicYearId: testYear.id,
      termId: testTermId,
      name: 'Schedule $index',
      start: DateTime(2025, 9, 8, 8 + index),
      duration: const Duration(minutes: 100),
      cohortId: cohortsMock[index].id,
      courseId: coursesMock[index].id,
      programId: testProgramId,
      lecturerId: lecturersMock[index].id,
      roomId: roomsMock[index].id,
    ),
  );

  final expectedScheduleUIs = List.generate(
    3,
    (index) => CourseScheduleUI(
      id: '$index',
      academicYearId: testYear.id,
      termId: testTermId,
      name: 'Schedule $index',
      start: DateTime(2025, 9, 8, 8 + index),
      duration: const Duration(minutes: 100),
      cohortId: cohortsMock[index].id,
      courseId: coursesMock[index].id,
      programId: testProgramId,
      lecturerId: lecturersMock[index].id,
      roomId: roomsMock[index].id,
      cohort: cohortsMock[index],
      course: coursesMock[index],
      lecturer: lecturersMock[index],
      room: roomsMock[index],
    ),
  );

  final expectedCalendarUI = CourseScheduleCalendarUI(
    academicCalendar: AcademicCalendar(year: testYear),
    schedules: expectedScheduleUIs,
  );

  final testFilter = CourseScheduleFilter(
    academicYearId: testYear.id,
    termId: testTermId,
    programId: testProgramId,
  );

  const testCourseFilter = CourseFilter(programId: testProgramId);

  group('CourseSchedulesBloc', () {
    late WatchSingleAcademicYearUseCase watchSingleAcademicYearMock;
    late WatchCourseSchedulesUseCase watchCourseSchedulesMock;
    late WatchCohortsUseCase watchCohortsMock;
    late WatchCoursesUseCase watchCoursesMock;
    late WatchLecturersUseCase watchLecturersMock;
    late WatchRoomsUseCase watchRoomsMock;

    setUpAll(initializeMockDependencies);

    setUp(() {
      watchSingleAcademicYearMock = getIt<WatchSingleAcademicYearUseCase>();
      when(() => watchSingleAcademicYearMock(testYear.id))
          .thenAnswer((_) => Stream.value(AppResult.success(testYear)));

      watchCourseSchedulesMock = getIt<WatchCourseSchedulesUseCase>();
      when(() => watchCourseSchedulesMock(testFilter))
          .thenAnswer((_) => Stream.value(AppResult.success(testSchedules)));

      watchCohortsMock = getIt<WatchCohortsUseCase>();
      when(() => watchCohortsMock(null))
          .thenAnswer((_) => Stream.value(AppResult.success(cohortsMock)));

      watchCoursesMock = getIt<WatchCoursesUseCase>();
      when(() => watchCoursesMock(testCourseFilter))
          .thenAnswer((_) => Stream.value(AppResult.success(coursesMock)));

      watchLecturersMock = getIt<WatchLecturersUseCase>();
      when(() => watchLecturersMock())
          .thenAnswer((_) => Stream.value(AppResult.success(lecturersMock)));

      watchRoomsMock = getIt<WatchRoomsUseCase>();
      when(() => watchRoomsMock())
          .thenAnswer((_) => Stream.value(AppResult.success(roomsMock)));
    });

    tearDown(() {
      reset(watchSingleAcademicYearMock);
      reset(watchCourseSchedulesMock);
      reset(watchCohortsMock);
      reset(watchCoursesMock);
      reset(watchLecturersMock);
      reset(watchRoomsMock);
    });

    CourseSchedulesBloc buildBloc() {
      return CourseSchedulesBloc(
        watchSingleAcademicYear: watchSingleAcademicYearMock,
        watchCourseSchedules: watchCourseSchedulesMock,
        watchCohorts: watchCohortsMock,
        watchCourses: watchCoursesMock,
        watchLecturers: watchLecturersMock,
        watchRooms: watchRoomsMock,
      );
    }

    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const CourseSchedulesInitial());
    });

    group('CourseSchedulesSubscriptionRequested', () {
      blocTest<CourseSchedulesBloc, CourseSchedulesState>(
        'emits [CourseSchedulesLoadData, CourseSchedulesLoaded] '
        'when CourseSchedulesSubscriptionRequested is added and '
        'all use cases emit success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseSchedulesSubscriptionRequested(
            academicYearId: testYear.id,
            termId: testTermId,
            programId: testProgramId,
          ),
        ),
        expect: () => <CourseSchedulesState>[
          const CourseSchedulesLoadData(),
          CourseSchedulesLoaded(expectedCalendarUI),
        ],
        verify: (_) {
          verify(() => watchSingleAcademicYearMock(testYear.id)).called(1);
          verify(() => watchCourseSchedulesMock(testFilter)).called(1);
          verify(() => watchCohortsMock(null)).called(1);
          verify(() => watchCoursesMock(testCourseFilter)).called(1);
          verify(() => watchLecturersMock()).called(1);
          verify(() => watchRoomsMock()).called(1);
        },
      );

      blocTest<CourseSchedulesBloc, CourseSchedulesState>(
        'filters out schedules that do not match academicYearId, termId, '
        'or programId',
        setUp: () {
          when(() => watchCourseSchedulesMock(testFilter)).thenAnswer(
            (_) => Stream.value(
              AppResult.success([
                ...testSchedules,
                CourseSchedule(
                  id: 'diff_year',
                  academicYearId: 'different_year',
                  termId: testTermId,
                  name: 'Diff Year',
                  start: DateTime(2025, 9, 8, 8),
                  duration: const Duration(minutes: 100),
                  cohortId: cohortsMock.first.id,
                  courseId: coursesMock.first.id,
                  programId: testProgramId,
                  lecturerId: lecturersMock.first.id,
                  roomId: roomsMock.first.id,
                ),
                CourseSchedule(
                  id: 'diff_term',
                  academicYearId: testYear.id,
                  termId: 'different_term',
                  name: 'Diff Term',
                  start: DateTime(2025, 9, 8, 8),
                  duration: const Duration(minutes: 100),
                  cohortId: cohortsMock.first.id,
                  courseId: coursesMock.first.id,
                  programId: testProgramId,
                  lecturerId: lecturersMock.first.id,
                  roomId: roomsMock.first.id,
                ),
                CourseSchedule(
                  id: 'diff_program',
                  academicYearId: testYear.id,
                  termId: testTermId,
                  name: 'Diff Program',
                  start: DateTime(2025, 9, 8, 8),
                  duration: const Duration(minutes: 100),
                  cohortId: cohortsMock.first.id,
                  courseId: coursesMock.first.id,
                  programId: 'different_program',
                  lecturerId: lecturersMock.first.id,
                  roomId: roomsMock.first.id,
                ),
              ]),
            ),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseSchedulesSubscriptionRequested(
            academicYearId: testYear.id,
            termId: testTermId,
            programId: testProgramId,
          ),
        ),
        expect: () => <CourseSchedulesState>[
          const CourseSchedulesLoadData(),
          CourseSchedulesLoaded(expectedCalendarUI),
        ],
      );

      blocTest<CourseSchedulesBloc, CourseSchedulesState>(
        'skips schedules where cohort, course, lecturer, or room is not found',
        setUp: () {
          when(() => watchCourseSchedulesMock(testFilter)).thenAnswer(
            (_) => Stream.value(
              AppResult.success([
                ...testSchedules,
                CourseSchedule(
                  id: 'unknown_cohort',
                  academicYearId: testYear.id,
                  termId: testTermId,
                  name: 'Unknown Cohort',
                  start: DateTime(2025, 9, 8, 8),
                  duration: const Duration(minutes: 100),
                  cohortId: 'unknown_cohort_id',
                  courseId: coursesMock.first.id,
                  programId: testProgramId,
                  lecturerId: lecturersMock.first.id,
                  roomId: roomsMock.first.id,
                ),
                CourseSchedule(
                  id: 'unknown_course',
                  academicYearId: testYear.id,
                  termId: testTermId,
                  name: 'Unknown Course',
                  start: DateTime(2025, 9, 8, 8),
                  duration: const Duration(minutes: 100),
                  cohortId: cohortsMock.first.id,
                  courseId: 'unknown_course_id',
                  programId: testProgramId,
                  lecturerId: lecturersMock.first.id,
                  roomId: roomsMock.first.id,
                ),
                CourseSchedule(
                  id: 'unknown_lecturer',
                  academicYearId: testYear.id,
                  termId: testTermId,
                  name: 'Unknown Lecturer',
                  start: DateTime(2025, 9, 8, 8),
                  duration: const Duration(minutes: 100),
                  cohortId: cohortsMock.first.id,
                  courseId: coursesMock.first.id,
                  programId: testProgramId,
                  lecturerId: 'unknown_lecturer_id',
                  roomId: roomsMock.first.id,
                ),
                CourseSchedule(
                  id: 'unknown_room',
                  academicYearId: testYear.id,
                  termId: testTermId,
                  name: 'Unknown Room',
                  start: DateTime(2025, 9, 8, 8),
                  duration: const Duration(minutes: 100),
                  cohortId: cohortsMock.first.id,
                  courseId: coursesMock.first.id,
                  programId: testProgramId,
                  lecturerId: lecturersMock.first.id,
                  roomId: 'unknown_room_id',
                ),
              ]),
            ),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseSchedulesSubscriptionRequested(
            academicYearId: testYear.id,
            termId: testTermId,
            programId: testProgramId,
          ),
        ),
        expect: () => <CourseSchedulesState>[
          const CourseSchedulesLoadData(),
          CourseSchedulesLoaded(expectedCalendarUI),
        ],
      );

      blocTest<CourseSchedulesBloc, CourseSchedulesState>(
        'emits [CourseSchedulesLoadData, CourseSchedulesLoadFailed] '
        'when WatchSingleAcademicYearUseCase emits failure',
        setUp: () {
          when(() => watchSingleAcademicYearMock(testYear.id)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseSchedulesSubscriptionRequested(
            academicYearId: testYear.id,
            termId: testTermId,
            programId: testProgramId,
          ),
        ),
        expect: () => <CourseSchedulesState>[
          const CourseSchedulesLoadData(),
          CourseSchedulesLoadFailed(AppException.test()),
        ],
      );

      blocTest<CourseSchedulesBloc, CourseSchedulesState>(
        'emits [CourseSchedulesLoadData, CourseSchedulesLoadFailed] '
        'when WatchCourseSchedulesUseCase emits failure',
        setUp: () {
          when(() => watchCourseSchedulesMock(testFilter)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseSchedulesSubscriptionRequested(
            academicYearId: testYear.id,
            termId: testTermId,
            programId: testProgramId,
          ),
        ),
        expect: () => <CourseSchedulesState>[
          const CourseSchedulesLoadData(),
          CourseSchedulesLoadFailed(AppException.test()),
        ],
      );

      blocTest<CourseSchedulesBloc, CourseSchedulesState>(
        'emits [CourseSchedulesLoadData, CourseSchedulesLoadFailed] '
        'when WatchCohortsUseCase emits failure',
        setUp: () {
          when(() => watchCohortsMock(null)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseSchedulesSubscriptionRequested(
            academicYearId: testYear.id,
            termId: testTermId,
            programId: testProgramId,
          ),
        ),
        expect: () => <CourseSchedulesState>[
          const CourseSchedulesLoadData(),
          CourseSchedulesLoadFailed(AppException.test()),
        ],
      );

      blocTest<CourseSchedulesBloc, CourseSchedulesState>(
        'emits [CourseSchedulesLoadData, CourseSchedulesLoadFailed] '
        'when WatchCoursesUseCase emits failure',
        setUp: () {
          when(() => watchCoursesMock(testCourseFilter)).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseSchedulesSubscriptionRequested(
            academicYearId: testYear.id,
            termId: testTermId,
            programId: testProgramId,
          ),
        ),
        expect: () => <CourseSchedulesState>[
          const CourseSchedulesLoadData(),
          CourseSchedulesLoadFailed(AppException.test()),
        ],
      );

      blocTest<CourseSchedulesBloc, CourseSchedulesState>(
        'emits [CourseSchedulesLoadData, CourseSchedulesLoadFailed] '
        'when WatchLecturersUseCase emits failure',
        setUp: () {
          when(() => watchLecturersMock()).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseSchedulesSubscriptionRequested(
            academicYearId: testYear.id,
            termId: testTermId,
            programId: testProgramId,
          ),
        ),
        expect: () => <CourseSchedulesState>[
          const CourseSchedulesLoadData(),
          CourseSchedulesLoadFailed(AppException.test()),
        ],
      );

      blocTest<CourseSchedulesBloc, CourseSchedulesState>(
        'emits [CourseSchedulesLoadData, CourseSchedulesLoadFailed] '
        'when WatchRoomsUseCase emits failure',
        setUp: () {
          when(() => watchRoomsMock()).thenAnswer(
            (_) => Stream.value(AppResult.failure(AppException.test())),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseSchedulesSubscriptionRequested(
            academicYearId: testYear.id,
            termId: testTermId,
            programId: testProgramId,
          ),
        ),
        expect: () => <CourseSchedulesState>[
          const CourseSchedulesLoadData(),
          CourseSchedulesLoadFailed(AppException.test()),
        ],
      );
    });
  });
}
