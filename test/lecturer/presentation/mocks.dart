import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';

@LazySingleton(as: LecturersBloc, env: [Environment.test])
class MockLecturersBloc extends Mock implements LecturersBloc;

@LazySingleton(as: LecturerDetailBloc, env: [Environment.test])
class MockLecturerDetailBloc extends Mock implements LecturerDetailBloc;

@LazySingleton(as: LecturerMutationBloc, env: [Environment.test])
class MockLecturerMutationBloc extends Mock implements LecturerMutationBloc;
