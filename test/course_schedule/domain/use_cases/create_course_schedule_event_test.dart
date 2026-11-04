import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

import '../../../common/di_mocks.dart';

void main() {
  final year = AcademicYear(
    id: 'year_1',
    name: '2025/2026',
    startDate: DateTime(2025, 9),
    endDate: DateTime(2026, 8, 31),
  );

  final start = EventDateTime(
    date: DateTime(2025, 10),
    time: const Time(hour: 8, minute: 0),
  );
  final end = EventDateTime(
    date: DateTime(2025, 10),
    time: const Time(hour: 10, minute: 0),
  );

  const detail = CourseScheduleEventDetail(
    cohortId: 'cohort_1',
    courseId: 'course_1',
    programId: 'program_1',
    lecturerId: 'lecturer_1',
    roomId: 'room_1',
  );

  final params = CreateCourseScheduleEventParams(
    academicYearId: year.id,
    name: 'Kuliah Pemrograman Web',
    start: start,
    end: end,
    courseDetail: detail,
    recurrence: const ['RRULE:FREQ=WEEKLY'],
  );

  final event = CourseScheduleEvent(
    id: 'schedule_1',
    academicYearId: year.id,
    name: 'Kuliah Pemrograman Web',
    start: start,
    end: end,
    courseDetail: detail,
  );

  late IAcademicYearRepository academicYearRepositoryMock;
  late ICourseScheduleEventRepository courseScheduleEventRepositoryMock;
  late CreateCourseScheduleEventUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    academicYearRepositoryMock = getIt<IAcademicYearRepository>();
    courseScheduleEventRepositoryMock = getIt<ICourseScheduleEventRepository>();

    when(() => academicYearRepositoryMock.watchSingle(year.id)).thenAnswer(
      (_) => Stream.value(AppResult.success(year)),
    );
    when(() => courseScheduleEventRepositoryMock.save(params)).thenAnswer(
      (_) async => AppResult.success(event),
    );

    useCase = CreateCourseScheduleEventUseCase(
      academicYearRepository: academicYearRepositoryMock,
      courseScheduleEventRepository: courseScheduleEventRepositoryMock,
    );
  });

  tearDown(() {
    reset(academicYearRepositoryMock);
    reset(courseScheduleEventRepositoryMock);
  });

  group('CreateCourseScheduleEventUseCase', () {
    test(
      'returns failure when IAcademicYearRepository.watchSingle fails',
      () async {
        when(() => academicYearRepositoryMock.watchSingle(year.id)).thenAnswer(
          (_) => Stream.value(
            AppFailure<AcademicYear>(exception: AppException.test()),
          ),
        );

        final result = await useCase(params);

        expect(
          result,
          isA<AppFailure<CourseScheduleEvent>>().having(
            (e) => e.exception,
            'exception',
            AppException.test(),
          ),
        );
      },
    );

    test(
      'returns failure with academicCalendarEventOutsideYear when event date '
      'is outside academic year',
      () async {
        final outsideParams = CreateCourseScheduleEventParams(
          academicYearId: year.id,
          name: 'Kuliah Pemrograman Web',
          start: EventDateTime(
            date: DateTime(2024, 8),
            time: const Time(hour: 8, minute: 0),
          ),
          end: EventDateTime(
            date: DateTime(2024, 8),
            time: const Time(hour: 10, minute: 0),
          ),
          courseDetail: detail,
        );

        final result = await useCase(outsideParams);

        expect(
          result,
          isA<AppFailure<CourseScheduleEvent>>().having(
            (e) => e.exception.code,
            'exception.code',
            AppExceptionCode.academicCalendarEventOutsideYear,
          ),
        );
      },
    );

    test(
      'returns failure when ICourseScheduleEventRepository.save fails',
      () async {
        when(() => courseScheduleEventRepositoryMock.save(params)).thenAnswer(
          (_) async => AppFailure<CourseScheduleEvent>(
            exception: AppException.test(),
          ),
        );

        final result = await useCase(params);

        expect(
          result,
          isA<AppFailure<CourseScheduleEvent>>().having(
            (e) => e.exception,
            'exception',
            AppException.test(),
          ),
        );
      },
    );

    test('returns correct event when all operations succeed', () async {
      final result = await useCase(params);

      expect(result, AppResult.success(event));
    });
  });
}
