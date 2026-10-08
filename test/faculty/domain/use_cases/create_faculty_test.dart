import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/access_control/access_control.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../../access_control/mocks.dart';
import '../mocks.dart';

void main() {
  const params = CreateFacultyParams(name: 'name');
  const faculty = Faculty(id: 'id', name: 'name');
  late AccessControl accessControlMock;
  late IFacultyRepository facultyRepositoryMock;
  late CreateFacultyUseCase useCase;

  setUp(() {
    accessControlMock = MockAccessControl();
    when(
      () => accessControlMock.permissionCheck(
        action: .create,
        resource: .faculty,
      ),
    ).thenAnswer((_) async => true);

    facultyRepositoryMock = MockFacultyRepository();
    when(() => facultyRepositoryMock.save(name: params.name))
        .thenAnswer((_) async => AppResult.success(faculty));

    useCase = CreateFacultyUseCase(
      accessControl: accessControlMock,
      facultyRepository: facultyRepositoryMock,
    );
  });

  group('CreateFacultyUseCase', () {
    test('returns failure with code accessControlMockCheckFail '
        'when AccessControl.permissionCheck fails', () async {
      when(
        () => accessControlMock.permissionCheck(
          action: .create,
          resource: .faculty,
        ),
      ).thenAnswer((_) async => false);

      final result = await useCase(params);

      expect(
        result,
        isA<AppFailure<Faculty>>().having(
          (e) => e.exception.code,
          'exception.code',
          AppExceptionCode.accessControlCheckFail,
        ),
      );
    });

    test('returns failure when FacultyRepository.save fails', () async {
      when(() => facultyRepositoryMock.save(name: params.name)).thenAnswer(
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
      verify(
        () => accessControlMock.permissionCheck(
          action: .create,
          resource: .faculty,
        ),
      ).called(1);
      verify(() => facultyRepositoryMock.save(name: params.name)).called(1);
    });
  });
}
