import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/faculty/faculty.dart';

@Injectable(as: IFacultyRepository, env: [Environment.test])
class MockFacultyRepository extends Mock implements IFacultyRepository;

@Injectable(as: WatchFacultiesUseCase, env: [Environment.test])
class MockWatchFacultiesUseCase extends Mock implements WatchFacultiesUseCase;

@Injectable(as: CreateFacultyUseCase, env: [Environment.test])
class MockCreateFacultyUseCase extends Mock implements CreateFacultyUseCase;

@Injectable(as: UpdateFacultyUseCase, env: [Environment.test])
class MockUpdateFacultyUseCase extends Mock implements UpdateFacultyUseCase;

@Injectable(as: DeleteFacultyUseCase, env: [Environment.test])
class MockDeleteFacultyUseCase extends Mock implements DeleteFacultyUseCase;
