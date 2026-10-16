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
  late DeleteCourseUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    courseRepositoryMock = getIt<ICourseRepository>();
    when(() => courseRepositoryMock.delete(course.id))
        .thenAnswer((_) async => AppResult.success(null));

    useCase = DeleteCourseUseCase(
      courseRepository: courseRepositoryMock,
    );
  });

  tearDown(() {
    reset(courseRepositoryMock);
  });

  group('DeleteCourseUseCase', () {
    test('returns failure when CourseRepository.delete fails', () async {
      when(() => courseRepositoryMock.delete(course.id)).thenAnswer(
        (_) async => AppResult<Null>.failure(
          AppException.test(),
        ),
      );

      final result = await useCase(course);

      expect(
        result,
        isA<AppFailure<Null>>().having(
          (e) => e.exception,
          'exception',
          AppException.test(),
        ),
      );
    });

    test('returns correct null when all operations success', () async {
      final result = await useCase(course);

      expect(result, AppResult.success(null));
      verify(() => courseRepositoryMock.delete(course.id)).called(1);
    });
  });
}
