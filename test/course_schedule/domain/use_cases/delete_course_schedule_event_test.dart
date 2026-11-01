import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

import '../../../common/di_mocks.dart';

void main() {
  final event = CourseScheduleEvent(
    id: 'schedule_1',
    academicYearId: 'year_1',
    name: 'Kuliah Pemrograman Web',
    start: EventDateTime(
      date: DateTime(2025, 9),
      time: const Time(hour: 8, minute: 0),
    ),
    end: EventDateTime(
      date: DateTime(2025, 9),
      time: const Time(hour: 10, minute: 0),
    ),
    courseDetail: const CourseScheduleEventDetail(
      cohortId: 'cohort_1',
      courseId: 'course_1',
      programId: 'program_1',
      lecturerId: 'lecturer_1',
      roomId: 'room_1',
    ),
  );

  late ICourseScheduleEventRepository repositoryMock;
  late DeleteCourseScheduleEventUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<ICourseScheduleEventRepository>();
    when(() => repositoryMock.delete(event.id))
        .thenAnswer((_) async => AppResult.success(null));

    useCase = DeleteCourseScheduleEventUseCase(
      courseScheduleEventRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('DeleteCourseScheduleEventUseCase', () {
    test(
      'returns failure when ICourseScheduleEventRepository.delete fails',
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
