import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/course.dart';

import '../../../common/di_mocks.dart';

void main() {
  final courses = List.generate(
    5,
    (index) => Course(
      id: '$index',
      programId: 'program_1',
      code: 'CS10$index',
      name: 'name $index',
      semester: index + 1,
      credit: 3,
    ),
  );
  late ICourseRepository courseRepositoryMock;
  late WatchCoursesUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    courseRepositoryMock = getIt<ICourseRepository>();
    when(courseRepositoryMock.watch)
        .thenAnswer((_) => Stream.value(AppResult.success(courses)));

    useCase = WatchCoursesUseCase(
      courseRepository: courseRepositoryMock,
    );
  });

  tearDown(() {
    reset(courseRepositoryMock);
  });

  group('WatchCoursesUseCase', () {
    test('emits correct list of Course', () async {
      final stream = useCase(null);

      expect(stream, emits(AppResult.success(courses)));
    });

    test('emits failure when repo emits failure', () {
      when(courseRepositoryMock.watch).thenAnswer(
        (_) => Stream.value(
          AppFailure<List<Course>>(exception: AppException.test()),
        ),
      );

      final stream = useCase(null);

      expect(
        stream,
        emits(AppFailure<List<Course>>(exception: AppException.test())),
      );
    });
  });
}
