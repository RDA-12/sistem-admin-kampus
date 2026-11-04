import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

import '../../../common/di_mocks.dart';
import '../mocks.dart';

void main() {
  late ICourseScheduleRepository repositoryMock;
  late WatchCourseSchedulesUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<ICourseScheduleRepository>();
    when(repositoryMock.watch).thenAnswer(
      (_) => Stream.value(AppResult.success(courseSchedulesMock)),
    );

    useCase = WatchCourseSchedulesUseCase(
      courseScheduleRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('WatchCourseSchedulesUseCase', () {
    test('emits correct list of CourseSchedule', () async {
      final stream = useCase(null);

      expect(stream, emits(AppResult.success(courseSchedulesMock)));
    });

    test('emits failure when repo emits failure', () {
      when(repositoryMock.watch).thenAnswer(
        (_) => Stream.value(
          AppFailure<List<CourseSchedule>>(
            exception: AppException.test(),
          ),
        ),
      );

      final stream = useCase(null);

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
