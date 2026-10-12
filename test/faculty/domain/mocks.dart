import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/faculty/faculty.dart';

@LazySingleton(as: IFacultyRepository, env: [Environment.test])
class MockFacultyRepository extends Mock implements IFacultyRepository;

@LazySingleton(as: WatchFacultiesUseCase, env: [Environment.test])
class MockWatchFacultiesUseCase extends Mock implements WatchFacultiesUseCase;

@LazySingleton(as: CreateFacultyUseCase, env: [Environment.test])
class MockCreateFacultyUseCase extends Mock implements CreateFacultyUseCase;

@LazySingleton(as: UpdateFacultyUseCase, env: [Environment.test])
class MockUpdateFacultyUseCase extends Mock implements UpdateFacultyUseCase;

@LazySingleton(as: DeleteFacultyUseCase, env: [Environment.test])
class MockDeleteFacultyUseCase extends Mock implements DeleteFacultyUseCase;

@LazySingleton(as: WatchSingleFacultyUseCase, env: [Environment.test])
class MockWatchSingleFacultyUseCase extends Mock
    implements WatchSingleFacultyUseCase;

final facultiesMock = List<Faculty>.generate(
  5,
  (index) => Faculty(id: '$index', name: 'name $index'),
);
const facultyMock = Faculty(id: 'id', name: 'name');
