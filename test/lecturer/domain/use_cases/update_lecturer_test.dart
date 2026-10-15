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
  const params = UpdateLecturerParams(
    lecturer,
    name: 'name',
    pangkatGolongan: 'III/a',
  );
  late ILecturerRepository lecturerRepositoryMock;
  late UpdateLecturerUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    lecturerRepositoryMock = getIt<ILecturerRepository>();
    when(() => lecturerRepositoryMock.update(lecturer.id, args: params))
        .thenAnswer((_) async => AppResult.success(lecturer));

    useCase = UpdateLecturerUseCase(
      lecturerRepository: lecturerRepositoryMock,
    );
  });

  tearDown(() {
    reset(lecturerRepositoryMock);
  });

  group('UpdateLecturerUseCase', () {
    test('returns failure when LecturerRepository.update fails', () async {
      when(() => lecturerRepositoryMock.update(lecturer.id, args: params))
          .thenAnswer(
            (_) async => AppResult<Lecturer>.failure(
              AppException.test(),
            ),
          );

      final result = await useCase(params);

      expect(
        result,
        isA<AppFailure<Lecturer>>().having(
          (e) => e.exception,
          'exception',
          AppException.test(),
        ),
      );
    });

    test('returns correct Lecturer when all operations success', () async {
      final result = await useCase(params);

      expect(result, AppResult.success(lecturer));
      verify(() => lecturerRepositoryMock.update(lecturer.id, args: params))
          .called(1);
    });
  });
}
