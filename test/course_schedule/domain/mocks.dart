import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

@LazySingleton(as: ICourseScheduleRepository, env: [Environment.test])
class MockCourseScheduleRepository extends Mock
    implements ICourseScheduleRepository;

@LazySingleton(as: CreateCourseScheduleUseCase, env: [Environment.test])
class MockCreateCourseScheduleUseCase extends Mock
    implements CreateCourseScheduleUseCase;

@LazySingleton(as: UpdateCourseScheduleUseCase, env: [Environment.test])
class MockUpdateCourseScheduleUseCase extends Mock
    implements UpdateCourseScheduleUseCase;

@LazySingleton(as: DeleteCourseScheduleUseCase, env: [Environment.test])
class MockDeleteCourseScheduleUseCase extends Mock
    implements DeleteCourseScheduleUseCase;

@LazySingleton(as: WatchCourseSchedulesUseCase, env: [Environment.test])
class MockWatchCourseSchedulesUseCase extends Mock
    implements WatchCourseSchedulesUseCase;

@LazySingleton(
  as: WatchCourseSchedulesByYearUseCase,
  env: [Environment.test],
)
class MockWatchCourseSchedulesByYearUseCase extends Mock
    implements WatchCourseSchedulesByYearUseCase;

@LazySingleton(
  as: WatchCourseSchedulesByCohortUseCase,
  env: [Environment.test],
)
class MockWatchCourseSchedulesByCohortUseCase extends Mock
    implements WatchCourseSchedulesByCohortUseCase;

final courseScheduleEventsMock = List<CourseSchedule>.generate(
  3,
  (index) => CourseSchedule(
    id: 'schedule_event_$index',
    academicYearId: 'year_1',
    termId: 'term_1',
    name: 'Schedule Event $index',
    start: DateTime(2025, 9, 8 + index, 8 + index),
    durationInMinutes: 100,
    cohortId: 'cohort_$index',
    courseId: 'course_1',
    programId: 'program_1',
    lecturerId: 'lecturer_1',
    roomId: 'room_1',
  ),
);

final CourseSchedule courseScheduleEventMock = courseScheduleEventsMock.first;
