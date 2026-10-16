import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/course.dart';

import '../../../common/di_mocks.dart';

void main() {
  const course = Course(
    id: 'id',
    programId: 'program_1',
    code: 'CS101',
    name: 'name',
    semester: 1,
    credit: 3,
  );
  late ICourseRepository courseRepositoryMock;
  late WatchSingleCourseUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    courseRepositoryMock = getIt<ICourseRepository>();
    when(() => courseRepositoryMock.watchSingle('id'))
        .thenAnswer((_) => Stream.value(AppResult.success(course)));

    useCase = WatchSingleCourseUseCase(
      courseRepository: courseRepositoryMock,
    );
  });

  tearDown(() {
    reset(courseRepositoryMock);
  });

  group('WatchSingleCourseUseCase', () {
    test('emits correct Course', () async {
      final stream = useCase('id');

      expect(stream, emits(AppResult.success(course)));
    });

    test('emits failure when repo emits failure', () {
      when(() => courseRepositoryMock.watchSingle('id')).thenAnswer(
        (_) => Stream.value(
          AppFailure<Course>(exception: AppException.test()),
        ),
      );

      final stream = useCase('id');

      expect(
        stream,
        emits(AppFailure<Course>(exception: AppException.test())),
      );
    });
  });
}
