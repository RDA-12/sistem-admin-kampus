import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

import '../../../common/di_mocks.dart';

void main() {
  final start = DateTime(2025, 9, 8, 8);
  const duration = Duration(minutes: 100);
  const filterYear1 = CourseScheduleFilter(academicYearId: 'year_1');
  const filterYear2 = CourseScheduleFilter(academicYearId: 'year_2');

  final academicYear = AcademicYear(
    id: 'year_1',
    name: '2025/2026',
    startDate: DateTime(2025, 9),
    endDate: DateTime(2026, 8, 31),
  );

  final academicYear2 = AcademicYear(
    id: 'year_2',
    name: '2026/2027',
    startDate: DateTime(2026, 9),
    endDate: DateTime(2027, 8, 31),
  );

  final courseSchedule = CourseSchedule(
    id: 'schedule_1',
    academicYearId: 'year_1',
    termId: 'term_1',
    programId: 'program_1',
    name: 'Kuliah Pemrograman Web',
    start: start,
    duration: duration,
    cohortId: 'cohort_1',
    courseId: 'course_1',
    lecturerId: 'lecturer_1',
    roomId: 'room_1',
  );

  final updatedSchedule = CourseSchedule(
    id: 'schedule_1',
    academicYearId: 'year_1',
    termId: 'term_1',
    programId: 'program_1',
    name: 'Updated Kuliah',
    start: start,
    duration: duration,
    cohortId: 'cohort_1',
    courseId: 'course_1',
    lecturerId: 'lecturer_1',
    roomId: 'room_1',
  );

  final params = UpdateCourseScheduleParams(
    courseSchedule,
    name: 'Updated Kuliah',
  );

  late IAcademicYearRepository academicYearRepositoryMock;
  late ICourseScheduleRepository courseScheduleRepositoryMock;
  late UpdateCourseScheduleUseCase useCase;

  setUpAll(() {
    initializeMockDependencies();
    registerFallbackValue(params);
    registerFallbackValue(const CourseScheduleFilter());
  });

  setUp(() {
    academicYearRepositoryMock = getIt<IAcademicYearRepository>();
    courseScheduleRepositoryMock = getIt<ICourseScheduleRepository>();

    when(
      () => academicYearRepositoryMock.watchSingle('year_1'),
    ).thenAnswer((_) => Stream.value(AppResult.success(academicYear)));

    when(
      () => academicYearRepositoryMock.watchSingle('year_2'),
    ).thenAnswer((_) => Stream.value(AppResult.success(academicYear2)));

    when(
      () => courseScheduleRepositoryMock.watch(filterYear1),
    ).thenAnswer((_) => Stream.value(AppResult.success([courseSchedule])));

    when(
      () => courseScheduleRepositoryMock.watch(filterYear2),
    ).thenAnswer((_) => Stream.value(AppResult.success(const [])));

    when(
      () => courseScheduleRepositoryMock.update(
        courseSchedule.id,
        args: params,
      ),
    ).thenAnswer((_) async => AppResult.success(updatedSchedule));

    useCase = UpdateCourseScheduleUseCase(
      academicYearRepository: academicYearRepositoryMock,
      courseScheduleRepository: courseScheduleRepositoryMock,
    );
  });

  tearDown(() {
    reset(academicYearRepositoryMock);
    reset(courseScheduleRepositoryMock);
  });

  group('UpdateCourseScheduleUseCase', () {
    test(
      'returns failure when IAcademicYearRepository.watchSingle fails',
      () async {
        when(
          () => academicYearRepositoryMock.watchSingle('year_1'),
        ).thenAnswer(
          (_) => Stream.value(
            AppFailure<AcademicYear>(exception: AppException.test()),
          ),
        );

        final result = await useCase(params);

        expect(
          result,
          isA<AppFailure<CourseSchedule>>().having(
            (e) => e.exception,
            'exception',
            AppException.test(),
          ),
        );
        verifyNever(
          () => courseScheduleRepositoryMock.watch(any()),
        );
        verifyNever(
          () => courseScheduleRepositoryMock.update(
            any(),
            args: any(named: 'args'),
          ),
        );
      },
    );

    test(
      'returns failure when ICourseScheduleRepository.watch fails',
      () async {
        when(
          () => courseScheduleRepositoryMock.watch(filterYear1),
        ).thenAnswer(
          (_) => Stream.value(
            AppFailure<List<CourseSchedule>>(exception: AppException.test()),
          ),
        );

        final result = await useCase(params);

        expect(
          result,
          isA<AppFailure<CourseSchedule>>().having(
            (e) => e.exception,
            'exception',
            AppException.test(),
          ),
        );
        verifyNever(
          () => courseScheduleRepositoryMock.update(
            any(),
            args: any(named: 'args'),
          ),
        );
      },
    );

    test(
      'returns failure when CourseCalendar detects collision',
      () async {
        final existingSchedule = CourseSchedule(
          id: 'schedule_existing',
          academicYearId: 'year_1',
          termId: 'term_1',
          programId: 'program_1',
          name: 'Existing Schedule',
          start: start,
          duration: duration,
          cohortId: 'cohort_other',
          courseId: 'course_other',
          lecturerId: 'lecturer_other',
          roomId: 'room_2',
        );
        when(
          () => courseScheduleRepositoryMock.watch(filterYear1),
        ).thenAnswer(
          (_) => Stream.value(
            AppResult.success([courseSchedule, existingSchedule]),
          ),
        );

        final collisionParams = UpdateCourseScheduleParams(
          courseSchedule,
          roomId: 'room_2',
        );

        final result = await useCase(collisionParams);

        expect(
          result,
          isA<AppFailure<CourseSchedule>>().having(
            (e) => e.exception,
            'exception',
            isA<CourseScheduleCollisionException>(),
          ),
        );
        verifyNever(
          () => courseScheduleRepositoryMock.update(
            any(),
            args: any(named: 'args'),
          ),
        );
      },
    );

    test(
      'returns failure when ICourseScheduleRepository.update fails',
      () async {
        when(
          () => courseScheduleRepositoryMock.update(
            courseSchedule.id,
            args: params,
          ),
        ).thenAnswer(
          (_) async => AppFailure<CourseSchedule>(
            exception: AppException.test(),
          ),
        );

        final result = await useCase(params);

        expect(
          result,
          isA<AppFailure<CourseSchedule>>().having(
            (e) => e.exception,
            'exception',
            AppException.test(),
          ),
        );
      },
    );

    test('returns correct course schedule when update succeeds', () async {
      final result = await useCase(params);

      expect(result, AppResult.success(updatedSchedule));
      verify(() => academicYearRepositoryMock.watchSingle('year_1')).called(1);
      verify(
        () => courseScheduleRepositoryMock.watch(filterYear1),
      ).called(1);
      verify(
        () => courseScheduleRepositoryMock.update(
          courseSchedule.id,
          args: params,
        ),
      ).called(1);
    });

    test(
      'uses params.academicYearId when provided instead of '
      'courseSchedule.academicYearId',
      () async {
        final paramsWithNewYear = UpdateCourseScheduleParams(
          courseSchedule,
          academicYearId: 'year_2',
        );
        when(
          () => courseScheduleRepositoryMock.update(
            courseSchedule.id,
            args: paramsWithNewYear,
          ),
        ).thenAnswer((_) async => AppResult.success(updatedSchedule));

        final result = await useCase(paramsWithNewYear);

        expect(result, AppResult.success(updatedSchedule));
        verify(
          () => academicYearRepositoryMock.watchSingle('year_2'),
        ).called(1);
        verify(
          () => courseScheduleRepositoryMock.watch(filterYear2),
        ).called(1);
      },
    );
  });
}
