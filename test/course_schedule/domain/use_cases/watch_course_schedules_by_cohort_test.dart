import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

import '../../../common/di_mocks.dart';
import '../mocks.dart';

void main() {
  late ICourseScheduleRepository repositoryMock;
  late WatchCourseSchedulesByCohortUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<ICourseScheduleRepository>();
    when(() => repositoryMock.watchByCohort('cohort_0')).thenAnswer(
      (_) => Stream.value(AppResult.success([courseSchedulesMock.first])),
    );

    useCase = WatchCourseSchedulesByCohortUseCase(
      courseScheduleRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('WatchCourseSchedulesByCohortUseCase', () {
    test(
      'emits correct list of CourseSchedule for cohort',
      () async {
        final stream = useCase('cohort_0');

        expect(
          stream,
          emits(AppResult.success([courseSchedulesMock.first])),
        );
      },
    );

    test('emits failure when repo emits failure', () {
      when(() => repositoryMock.watchByCohort('cohort_0')).thenAnswer(
        (_) => Stream.value(
          AppFailure<List<CourseSchedule>>(
            exception: AppException.test(),
          ),
        ),
      );

      final stream = useCase('cohort_0');

      expect(
        stream,
        emits(
          AppFailure<List<CourseSchedule>>(
            exception: AppException.test(),
          ),
        ),
      );
    });
  });
}
