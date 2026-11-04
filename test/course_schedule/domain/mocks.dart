import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

@LazySingleton(as: ICourseScheduleEventRepository, env: [Environment.test])
class MockCourseScheduleEventRepository extends Mock
    implements ICourseScheduleEventRepository;

@LazySingleton(as: CreateCourseScheduleEventUseCase, env: [Environment.test])
class MockCreateCourseScheduleEventUseCase extends Mock
    implements CreateCourseScheduleEventUseCase;

@LazySingleton(as: UpdateCourseScheduleEventUseCase, env: [Environment.test])
class MockUpdateCourseScheduleEventUseCase extends Mock
    implements UpdateCourseScheduleEventUseCase;

@LazySingleton(as: DeleteCourseScheduleEventUseCase, env: [Environment.test])
class MockDeleteCourseScheduleEventUseCase extends Mock
    implements DeleteCourseScheduleEventUseCase;

@LazySingleton(as: WatchCourseScheduleEventsUseCase, env: [Environment.test])
class MockWatchCourseScheduleEventsUseCase extends Mock
    implements WatchCourseScheduleEventsUseCase;

@LazySingleton(
  as: WatchCourseScheduleEventsByYearUseCase,
  env: [Environment.test],
)
class MockWatchCourseScheduleEventsByYearUseCase extends Mock
    implements WatchCourseScheduleEventsByYearUseCase;

@LazySingleton(
  as: WatchCourseScheduleEventsByCohortUseCase,
  env: [Environment.test],
)
class MockWatchCourseScheduleEventsByCohortUseCase extends Mock
    implements WatchCourseScheduleEventsByCohortUseCase;

final courseScheduleEventsMock = List<CourseScheduleEvent>.generate(
  3,
  (index) => CourseScheduleEvent(
    id: 'schedule_event_$index',
    academicYearId: 'year_1',
    name: 'Schedule Event $index',
    start: EventDateTime(
      date: DateTime(2025, 9, 10 + index),
      time: const Time(hour: 8, minute: 0),
    ),
    end: EventDateTime(
      date: DateTime(2025, 9, 10 + index),
      time: const Time(hour: 10, minute: 0),
    ),
    courseDetail: CourseScheduleEventDetail(
      cohortId: 'cohort_$index',
      courseId: 'course_1',
      programId: 'program_1',
      lecturerId: 'lecturer_1',
      roomId: 'room_1',
    ),
  ),
);

final CourseScheduleEvent courseScheduleEventMock =
    courseScheduleEventsMock.first;
