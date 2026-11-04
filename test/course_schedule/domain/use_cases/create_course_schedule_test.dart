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

  final params = CreateCourseScheduleParams(
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

  final academicYear = AcademicYear(
    id: 'year_1',
    name: '2025/2026',
    startDate: DateTime(2025, 9),
    endDate: DateTime(2026, 8, 31),
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

  late IAcademicYearRepository academicYearRepositoryMock;
  late ICourseScheduleRepository courseScheduleRepositoryMock;
  late CreateCourseScheduleUseCase useCase;

  setUpAll(() {
    initializeMockDependencies();
    registerFallbackValue(params);
  });

  setUp(() {
    academicYearRepositoryMock = getIt<IAcademicYearRepository>();
    courseScheduleRepositoryMock = getIt<ICourseScheduleRepository>();

    when(
      () => academicYearRepositoryMock.watchSingle('year_1'),
    ).thenAnswer((_) => Stream.value(AppResult.success(academicYear)));

    when(
      () => courseScheduleRepositoryMock.watchByAcademicYear('year_1'),
    ).thenAnswer((_) => Stream.value(AppResult.success(const [])));

    when(
      () => courseScheduleRepositoryMock.save(params),
    ).thenAnswer((_) async => AppResult.success(courseSchedule));

    useCase = CreateCourseScheduleUseCase(
      academicYearRepository: academicYearRepositoryMock,
      courseScheduleRepository: courseScheduleRepositoryMock,
    );
  });

  tearDown(() {
    reset(academicYearRepositoryMock);
    reset(courseScheduleRepositoryMock);
  });

  group('CreateCourseScheduleUseCase', () {
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
          () => courseScheduleRepositoryMock.watchByAcademicYear(any()),
        );
        verifyNever(() => courseScheduleRepositoryMock.save(any()));
      },
    );

    test(
      'returns failure when '
      'ICourseScheduleRepository.watchByAcademicYear fails',
      () async {
        when(
          () => courseScheduleRepositoryMock.watchByAcademicYear('year_1'),
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
        verifyNever(() => courseScheduleRepositoryMock.save(any()));
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
          roomId: params.roomId, // same room!
        );
        when(
          () => courseScheduleRepositoryMock.watchByAcademicYear('year_1'),
        ).thenAnswer(
          (_) => Stream.value(AppResult.success([existingSchedule])),
        );

        final result = await useCase(params);

        expect(
          result,
          isA<AppFailure<CourseSchedule>>().having(
            (e) => e.exception,
            'exception',
            isA<CourseScheduleCollisionException>(),
          ),
        );
        verifyNever(() => courseScheduleRepositoryMock.save(any()));
      },
    );

    test(
      'returns failure when ICourseScheduleRepository.save fails',
      () async {
        when(() => courseScheduleRepositoryMock.save(params)).thenAnswer(
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

    test(
      'returns correct course schedule when all operations succeed',
      () async {
        final result = await useCase(params);

        expect(result, AppResult.success(courseSchedule));
        verify(() => academicYearRepositoryMock.watchSingle('year_1'))
            .called(1);
        verify(
          () => courseScheduleRepositoryMock.watchByAcademicYear('year_1'),
        ).called(1);
        verify(() => courseScheduleRepositoryMock.save(params)).called(1);
      },
    );
  });
}
