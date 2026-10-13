import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/program/program.dart';

@LazySingleton(as: IProgramRepository, env: [Environment.test])
class MockProgramRepository extends Mock implements IProgramRepository;

@LazySingleton(as: WatchProgramsUseCase, env: [Environment.test])
class MockWatchProgramsUseCase extends Mock implements WatchProgramsUseCase;

@LazySingleton(as: WatchSingleProgramUseCase, env: [Environment.test])
class MockWatchSingleProgramUseCase extends Mock
    implements WatchSingleProgramUseCase;

@LazySingleton(as: CreateProgramUseCase, env: [Environment.test])
class MockCreateProgramUseCase extends Mock implements CreateProgramUseCase;

final programsMock = List<Program>.generate(
  5,
  (index) => Program(id: '$index', facultyId: 'faculty_1', name: 'name $index'),
);
const programMock = Program(id: 'id', facultyId: 'faculty_1', name: 'name');
