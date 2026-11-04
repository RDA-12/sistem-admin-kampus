import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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

  late ICourseScheduleRepository courseScheduleRepositoryMock;
  late CreateCourseScheduleUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    courseScheduleRepositoryMock = getIt<ICourseScheduleRepository>();

    when(() => courseScheduleRepositoryMock.save(params)).thenAnswer(
      (_) async => AppResult.success(courseSchedule),
    );

    useCase = CreateCourseScheduleUseCase(
      courseScheduleRepository: courseScheduleRepositoryMock,
    );
  });

  tearDown(() {
    reset(courseScheduleRepositoryMock);
  });

  group('CreateCourseScheduleUseCase', () {
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

    test('returns correct course schedule when save succeeds', () async {
      final result = await useCase(params);

      expect(result, AppResult.success(courseSchedule));
    });
  });
}
