import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

import '../../academic_calendar/domain/mocks.dart';
import '../../cohort/domain/mocks.dart';
import '../../course/domain/mocks.dart';
import '../../lecturer/domain/mocks.dart';
import '../../room/domain/mocks.dart';

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

final courseSchedulesMock = List<CourseSchedule>.generate(
  3,
  (index) => CourseSchedule(
    id: 'schedule_$index',
    academicYearId: 'year_1',
    termId: 'term_1',
    name: 'Schedule $index',
    start: DateTime(2025, 9, 8 + index, 8 + index),
    duration: const Duration(minutes: 100),
    cohortId: 'cohort_$index',
    courseId: 'course_1',
    programId: 'program_1',
    lecturerId: 'lecturer_1',
    roomId: 'room_1',
  ),
);

final CourseSchedule courseScheduleMock = courseSchedulesMock.first;

final courseSchedulesUIMock = List<CourseScheduleUI>.generate(
  3,
  (index) => CourseScheduleUI(
    id: 'schedule_$index',
    academicYearId: 'year_1',
    termId: 'term_1',
    name: 'Schedule $index',
    start: DateTime(2025, 9, 8 + index, 8 + index),
    duration: const Duration(minutes: 100),
    cohortId: cohortsMock[index].id,
    courseId: coursesMock[index].id,
    programId: 'program_1',
    lecturerId: lecturersMock[index].id,
    roomId: roomsMock[index].id,
    cohort: cohortsMock[index],
    course: coursesMock[index],
    lecturer: lecturersMock[index],
    room: roomsMock[index],
  ),
);

final CourseScheduleUI courseScheduleUIMock = courseSchedulesUIMock.first;

final courseScheduleCalendarUIMock = CourseScheduleCalendarUI(
  academicCalendar: AcademicCalendar(year: academicYearMock),
  schedules: courseSchedulesUIMock,
);
