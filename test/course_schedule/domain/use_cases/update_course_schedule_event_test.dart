import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

import '../../../common/di_mocks.dart';

void main() {
  final start = DateTime(2025, 9, 8, 8);
  const duration = Duration(minutes: 100);

  final event = CourseSchedule(
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

  final updatedEvent = CourseSchedule(
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
    event,
    name: 'Updated Kuliah',
  );

  late ICourseScheduleRepository courseScheduleRepositoryMock;
  late UpdateCourseScheduleUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    courseScheduleRepositoryMock = getIt<ICourseScheduleRepository>();

    when(
      () => courseScheduleRepositoryMock.update(
        event.id,
        args: params,
      ),
    ).thenAnswer((_) async => AppResult.success(updatedEvent));

    useCase = UpdateCourseScheduleUseCase(
      courseScheduleRepository: courseScheduleRepositoryMock,
    );
  });

  tearDown(() {
    reset(courseScheduleRepositoryMock);
  });

  group('UpdateCourseScheduleUseCase', () {
    test(
      'returns failure when ICourseScheduleRepository.update fails',
      () async {
        when(
          () => courseScheduleRepositoryMock.update(
            event.id,
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

    test('returns correct event when update succeeds', () async {
      final result = await useCase(params);

      expect(result, AppResult.success(updatedEvent));
    });
  });
}
