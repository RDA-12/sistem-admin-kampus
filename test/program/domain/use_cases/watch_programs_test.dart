import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';

void main() {
  final programs = List.generate(
    5,
    (index) => Program(
      id: '$index',
      facultyId: 'faculty_1',
      name: 'name $index',
    ),
  );
  late IProgramRepository programRepositoryMock;
  late WatchProgramsUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    programRepositoryMock = getIt<IProgramRepository>();
    when(() => programRepositoryMock.watch())
        .thenAnswer((_) => Stream.value(AppResult.success(programs)));

    useCase = WatchProgramsUseCase(
      programRepository: programRepositoryMock,
    );
  });

  group('WatchProgramsUseCase', () {
    test('emits correct list of Program when no filter provided', () async {
      final stream = useCase();

      expect(stream, emits(AppResult.success(programs)));
    });

    test('emits correct list of Program when filter provided', () async {
      const filter = ProgramFilter(facultyId: 'faculty_1');
      when(() => programRepositoryMock.watch(filter))
          .thenAnswer((_) => Stream.value(AppResult.success(programs)));

      final stream = useCase(filter);

      expect(stream, emits(AppResult.success(programs)));
    });

    test('emits failure when repo emits failure', () {
      when(() => programRepositoryMock.watch()).thenAnswer(
        (_) => Stream.value(
          AppFailure<List<Program>>(exception: AppException.test()),
        ),
      );

      final stream = useCase();

      expect(
        stream,
        emits(AppFailure<List<Program>>(exception: AppException.test())),
      );
    });
  });
}
