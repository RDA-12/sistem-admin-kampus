import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';

void main() {
  const program = Program(id: 'id', facultyId: 'faculty_1', name: 'name');
  late IProgramRepository programRepositoryMock;
  late WatchSingleProgramUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    programRepositoryMock = getIt<IProgramRepository>();
    when(() => programRepositoryMock.watchSingle(program.id))
        .thenAnswer((_) => Stream.value(AppResult.success(program)));

    useCase = WatchSingleProgramUseCase(
      programRepository: programRepositoryMock,
    );
  });

  tearDown(() {
    reset(programRepositoryMock);
  });

  group('WatchSingleProgramUseCase', () {
    test('emits correct Program', () async {
      final stream = useCase(program.id);

      expect(stream, emits(AppResult.success(program)));
      verify(() => programRepositoryMock.watchSingle(program.id)).called(1);
    });

    test('emits failure when repo emits failure', () {
      when(() => programRepositoryMock.watchSingle(program.id)).thenAnswer(
        (_) => Stream.value(
          AppFailure<Program>(exception: AppException.test()),
        ),
      );

      final stream = useCase(program.id);

      expect(
        stream,
        emits(AppFailure<Program>(exception: AppException.test())),
      );
    });
  });
}
