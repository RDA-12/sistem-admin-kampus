import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

import '../../../common/di_mocks.dart';

void main() {
  final event = CourseSchedule(
    id: 'schedule_1',
    academicYearId: 'year_1',
    termId: 'term_1',
    programId: 'program_1',
    name: 'Kuliah Pemrograman Web',
    start: DateTime(2025, 9, 8, 8),
    durationInMinutes: 100,
    cohortId: 'cohort_1',
    courseId: 'course_1',
    lecturerId: 'lecturer_1',
    roomId: 'room_1',
  );

  late ICourseScheduleRepository repositoryMock;
  late DeleteCourseScheduleUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<ICourseScheduleRepository>();
    when(() => repositoryMock.delete(event.id))
        .thenAnswer((_) async => AppResult.success(null));

    useCase = DeleteCourseScheduleUseCase(
      courseScheduleRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('DeleteCourseScheduleUseCase', () {
    test(
      'returns failure when ICourseScheduleRepository.delete fails',
      () async {
        when(() => repositoryMock.delete(event.id)).thenAnswer(
          (_) async => AppResult<Null>.failure(
            AppException.test(),
          ),
        );

        final result = await useCase(event);

        expect(
          result,
          isA<AppFailure<Null>>().having(
            (e) => e.exception,
            'exception',
            AppException.test(),
          ),
        );
      },
    );

    test('returns correct null when all operations succeed', () async {
      final result = await useCase(event);

      expect(result, AppResult.success(null));
    });
  });
}
