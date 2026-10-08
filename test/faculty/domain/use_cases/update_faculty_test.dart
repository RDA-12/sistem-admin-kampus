import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/domain/use_cases/update_faculty.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../mocks.dart';

void main() {
  const faculty = Faculty(id: 'id', name: 'name');
  const params = UpdateFacultyParams(faculty, name: 'name');
  late IFacultyRepository facultyRepositoryMock;
  late UpdateFacultyUseCase useCase;

  setUp(() {
    facultyRepositoryMock = MockFacultyRepository();
    when(() => facultyRepositoryMock.update(faculty.id, name: params.name))
        .thenAnswer((_) async => AppResult.success(faculty));

    useCase = UpdateFacultyUseCase(
      facultyRepository: facultyRepositoryMock,
    );
  });

  group('UpdateFacultyUseCase', () {
    test('returns failure when FacultyRepository.save fails', () async {
      when(() => facultyRepositoryMock.update(faculty.id, name: params.name))
          .thenAnswer(
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
      verify(() => facultyRepositoryMock.update(faculty.id, name: params.name))
          .called(1);
    });
  });
}
