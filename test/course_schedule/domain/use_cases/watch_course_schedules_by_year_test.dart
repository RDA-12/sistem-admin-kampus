import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

import '../../../common/di_mocks.dart';
import '../mocks.dart';

void main() {
  late ICourseScheduleRepository repositoryMock;
  late WatchCourseSchedulesByYearUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<ICourseScheduleRepository>();
    when(() => repositoryMock.watchByAcademicYear('year_1')).thenAnswer(
      (_) => Stream.value(AppResult.success(courseSchedulesMock)),
    );

    useCase = WatchCourseSchedulesByYearUseCase(
      courseScheduleRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('WatchCourseSchedulesByYearUseCase', () {
    test(
      'emits correct list of CourseSchedule for academic year',
      () async {
        final stream = useCase('year_1');

        expect(stream, emits(AppResult.success(courseSchedulesMock)));
      },
    );

    test('emits failure when repo emits failure', () {
      when(() => repositoryMock.watchByAcademicYear('year_1')).thenAnswer(
        (_) => Stream.value(
          AppFailure<List<CourseSchedule>>(
            exception: AppException.test(),
          ),
        ),
      );

      final stream = useCase('year_1');

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
