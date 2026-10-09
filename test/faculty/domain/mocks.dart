import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/faculty/faculty.dart';

@Injectable(as: IFacultyRepository, env: [Environment.test])
class MockFacultyRepository extends Mock implements IFacultyRepository;
