import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';

void main() {
  const params = CreateProgramParams(facultyId: 'faculty_1', name: 'name');
  const program = Program(id: 'id', facultyId: 'faculty_1', name: 'name');
  late IProgramRepository programRepositoryMock;
  late CreateProgramUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    programRepositoryMock = getIt<IProgramRepository>();
    when(() => programRepositoryMock.save(params))
        .thenAnswer((_) async => AppResult.success(program));

    useCase = CreateProgramUseCase(
      programRepository: programRepositoryMock,
    );
  });

  tearDown(() {
    reset(programRepositoryMock);
  });

  group('CreateProgramUseCase', () {
    test('returns failure when ProgramRepository.save fails', () async {
      when(() => programRepositoryMock.save(params)).thenAnswer(
        (_) async => AppResult<Program>.failure(
          AppException.test(),
        ),
      );

      final result = await useCase(params);

      expect(
        result,
        isA<AppFailure<Program>>().having(
          (e) => e.exception,
          'exception',
          AppException.test(),
        ),
      );
    });

    test('returns correct Program when all operations success', () async {
      final result = await useCase(params);

      expect(result, AppResult.success(program));
      verify(() => programRepositoryMock.save(params)).called(1);
    });
  });
}
