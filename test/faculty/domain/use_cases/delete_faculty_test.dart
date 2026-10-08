import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../mocks.dart';

void main() {
  const facultyId = 'id';
  const faculty = Faculty(id: facultyId, name: 'name');
  late IFacultyRepository facultyRepositoryMock;
  late DeleteFacultyUseCase useCase;

  setUp(() {
    facultyRepositoryMock = MockFacultyRepository();
    when(() => facultyRepositoryMock.delete(faculty.id))
        .thenAnswer((_) async => AppResult.success(null));

    useCase = DeleteFacultyUseCase(
      facultyRepository: facultyRepositoryMock,
    );
  });

  group('DeleteFacultyUseCase', () {
    test('returns failure when FacultyRepository.delete fails', () async {
      when(() => facultyRepositoryMock.delete(facultyId)).thenAnswer(
        (_) async => AppResult<Null>.failure(
          AppException.test(),
        ),
      );

      final result = await useCase(faculty);

      expect(
        result,
        isA<AppFailure<Null>>().having(
          (e) => e.exception,
          'exception',
          AppException.test(),
        ),
      );
    });

    test('returns success when all operations success', () async {
      final result = await useCase(faculty);

      expect(result, AppResult.success(null));
      verify(() => facultyRepositoryMock.delete(facultyId)).called(1);
    });
  });
}
