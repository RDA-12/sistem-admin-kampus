import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../mocks.dart';

void main() {
  const params = CreateFacultyParams(name: 'name');
  const faculty = Faculty(id: 'id', name: 'name');
  late IFacultyRepository facultyRepositoryMock;
  late CreateFacultyUseCase useCase;

  setUp(() {
    facultyRepositoryMock = MockFacultyRepository();
    when(() => facultyRepositoryMock.save(params))
        .thenAnswer((_) async => AppResult.success(faculty));

    useCase = CreateFacultyUseCase(
      facultyRepository: facultyRepositoryMock,
    );
  });

  group('CreateFacultyUseCase', () {
    test('returns failure when FacultyRepository.save fails', () async {
      when(() => facultyRepositoryMock.save(params)).thenAnswer(
        (_) async => AppResult<Faculty>.failure(
          AppException.test(),
        ),
      );

      final result = await useCase(params);

      expect(
        result,
        isA<AppFailure<Faculty>>().having(
          (e) => e.exception,
          'exception',
          AppException.test(),
        ),
      );
    });

    test('returns correct Faculty when all operations success', () async {
      final result = await useCase(params);

      expect(result, AppResult.success(faculty));
      verify(() => facultyRepositoryMock.save(params)).called(1);
    });
  });
}
