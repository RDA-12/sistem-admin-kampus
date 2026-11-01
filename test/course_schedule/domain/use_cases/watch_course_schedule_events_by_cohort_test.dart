import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

import '../../../common/di_mocks.dart';
import '../mocks.dart';

void main() {
  late ICourseScheduleEventRepository repositoryMock;
  late WatchCourseScheduleEventsByCohortUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<ICourseScheduleEventRepository>();
    when(() => repositoryMock.watchByCohort('cohort_0')).thenAnswer(
      (_) => Stream.value(AppResult.success([courseScheduleEventsMock.first])),
    );

    useCase = WatchCourseScheduleEventsByCohortUseCase(
      courseScheduleEventRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('WatchCourseScheduleEventsByCohortUseCase', () {
    test(
      'emits correct list of CourseScheduleEvent for cohort',
      () async {
        final stream = useCase('cohort_0');

        expect(
          stream,
          emits(AppResult.success([courseScheduleEventsMock.first])),
        );
      },
    );

    test('emits failure when repo emits failure', () {
      when(() => repositoryMock.watchByCohort('cohort_0')).thenAnswer(
        (_) => Stream.value(
          AppFailure<List<CourseScheduleEvent>>(
            exception: AppException.test(),
          ),
        ),
      );

      final stream = useCase('cohort_0');

      expect(
        stream,
        emits(
          AppFailure<List<CourseScheduleEvent>>(
            exception: AppException.test(),
          ),
        ),
      );
    });
  });
}
