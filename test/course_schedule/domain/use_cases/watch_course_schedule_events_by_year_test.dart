import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

import '../../../common/di_mocks.dart';
import '../mocks.dart';

void main() {
  late ICourseScheduleEventRepository repositoryMock;
  late WatchCourseScheduleEventsByYearUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<ICourseScheduleEventRepository>();
    when(() => repositoryMock.watchByAcademicYear('year_1')).thenAnswer(
      (_) => Stream.value(AppResult.success(courseScheduleEventsMock)),
    );

    useCase = WatchCourseScheduleEventsByYearUseCase(
      courseScheduleEventRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('WatchCourseScheduleEventsByYearUseCase', () {
    test(
      'emits correct list of CourseScheduleEvent for academic year',
      () async {
        final stream = useCase('year_1');

        expect(stream, emits(AppResult.success(courseScheduleEventsMock)));
      },
    );

    test('emits failure when repo emits failure', () {
      when(() => repositoryMock.watchByAcademicYear('year_1')).thenAnswer(
        (_) => Stream.value(
          AppFailure<List<CourseScheduleEvent>>(
            exception: AppException.test(),
          ),
        ),
      );

      final stream = useCase('year_1');

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
