import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/course.dart';

import '../../../common/di_mocks.dart';

void main() {
  const params = CreateCourseParams(
    programId: 'program_1',
    code: 'CS101',
    name: 'name',
    semester: 1,
    credit: 3,
  );
  const course = Course(
    id: 'id',
    programId: 'program_1',
    code: 'CS101',
    name: 'name',
    semester: 1,
    credit: 3,
  );
  late ICourseRepository courseRepositoryMock;
  late CreateCourseUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    courseRepositoryMock = getIt<ICourseRepository>();
    when(() => courseRepositoryMock.save(params))
        .thenAnswer((_) async => AppResult.success(course));

    useCase = CreateCourseUseCase(
      courseRepository: courseRepositoryMock,
    );
  });

  tearDown(() {
    reset(courseRepositoryMock);
  });

  group('CreateCourseUseCase', () {
    test('returns failure when CourseRepository.save fails', () async {
      when(() => courseRepositoryMock.save(params)).thenAnswer(
        (_) async => AppResult<Course>.failure(
          AppException.test(),
        ),
      );

      final result = await useCase(params);

      expect(
        result,
        isA<AppFailure<Course>>().having(
          (e) => e.exception,
          'exception',
          AppException.test(),
        ),
      );
    });

    test('returns correct Course when all operations success', () async {
      final result = await useCase(params);

      expect(result, AppResult.success(course));
      verify(() => courseRepositoryMock.save(params)).called(1);
    });
  });
}
