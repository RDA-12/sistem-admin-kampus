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
  const params = UpdateProgramParams(program, name: 'name');
  late IProgramRepository programRepositoryMock;
  late UpdateProgramUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    programRepositoryMock = getIt<IProgramRepository>();
    when(() => programRepositoryMock.update(program.id, args: params))
        .thenAnswer((_) async => AppResult.success(program));

    useCase = UpdateProgramUseCase(
      programRepository: programRepositoryMock,
    );
  });

  tearDown(() {
    reset(programRepositoryMock);
  });

  group('UpdateProgramUseCase', () {
    test('returns failure when ProgramRepository.update fails', () async {
      when(() => programRepositoryMock.update(program.id, args: params))
          .thenAnswer(
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
      verify(() => programRepositoryMock.update(program.id, args: params))
          .called(1);
    });
  });
}
