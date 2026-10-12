import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/faculty/faculty.dart';

@LazySingleton(as: FacultyMutationBloc, env: [Environment.test])
class MockFacultyMutationBloc extends Mock implements FacultyMutationBloc;

@LazySingleton(as: FacultiesBloc, env: [Environment.test])
class MockFacultiesBloc extends Mock implements FacultiesBloc;

@LazySingleton(as: FacultyDetailBloc, env: [Environment.test])
class MockFacultyDetailBloc extends Mock implements FacultyDetailBloc;
