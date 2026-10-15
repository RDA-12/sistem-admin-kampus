import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';

import '../../../common/di_mocks.dart';

void main() {
  const lecturer = Lecturer(
    id: 'id',
    programId: 'program_1',
    name: 'name',
    pangkatGolongan: 'III/a',
  );
  late ILecturerRepository lecturerRepositoryMock;
  late DeleteLecturerUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    lecturerRepositoryMock = getIt<ILecturerRepository>();
    when(() => lecturerRepositoryMock.delete(lecturer.id))
        .thenAnswer((_) async => AppResult.success(null));

    useCase = DeleteLecturerUseCase(
      lecturerRepository: lecturerRepositoryMock,
    );
  });

  tearDown(() {
    reset(lecturerRepositoryMock);
  });

  group('DeleteLecturerUseCase', () {
    test('returns failure when LecturerRepository.delete fails', () async {
      when(() => lecturerRepositoryMock.delete(lecturer.id)).thenAnswer(
        (_) async => AppResult<Null>.failure(
          AppException.test(),
        ),
      );

      final result = await useCase(lecturer);

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
      final result = await useCase(lecturer);

      expect(result, AppResult.success(null));
      verify(() => lecturerRepositoryMock.delete(lecturer.id)).called(1);
    });
  });
}
