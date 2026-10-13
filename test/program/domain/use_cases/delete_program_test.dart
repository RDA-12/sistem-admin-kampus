import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';

void main() {
  const program = Program(
    id: 'id',
    facultyId: 'faculty_1',
    name: 'name',
  );
  late IProgramRepository programRepositoryMock;
  late DeleteProgramUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    programRepositoryMock = getIt<IProgramRepository>();
    when(() => programRepositoryMock.delete(program.id))
        .thenAnswer((_) async => AppResult.success(null));

    useCase = DeleteProgramUseCase(
      programRepository: programRepositoryMock,
    );
  });

  tearDown(() {
    reset(programRepositoryMock);
  });

  group('DeleteProgramUseCase', () {
    test('returns failure when ProgramRepository.delete fails', () async {
      when(() => programRepositoryMock.delete(program.id)).thenAnswer(
        (_) async => AppResult<Null>.failure(
          AppException.test(),
        ),
      );

      final result = await useCase(program);

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
      final result = await useCase(program);

      expect(result, AppResult.success(null));
      verify(() => programRepositoryMock.delete(program.id)).called(1);
    });
  });
}
