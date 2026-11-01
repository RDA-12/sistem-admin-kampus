import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

import '../../../common/di_mocks.dart';
import '../mocks.dart';

void main() {
  late ICourseScheduleEventRepository repositoryMock;
  late WatchCourseScheduleEventsUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<ICourseScheduleEventRepository>();
    when(repositoryMock.watch).thenAnswer(
      (_) => Stream.value(AppResult.success(courseScheduleEventsMock)),
    );

    useCase = WatchCourseScheduleEventsUseCase(
      courseScheduleEventRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('WatchCourseScheduleEventsUseCase', () {
    test('emits correct list of CourseScheduleEvent', () async {
      final stream = useCase(null);

      expect(stream, emits(AppResult.success(courseScheduleEventsMock)));
    });

    test('emits failure when repo emits failure', () {
      when(repositoryMock.watch).thenAnswer(
        (_) => Stream.value(
          AppFailure<List<CourseScheduleEvent>>(
            exception: AppException.test(),
          ),
        ),
      );

      final stream = useCase(null);

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
