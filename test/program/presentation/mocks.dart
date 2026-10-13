import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/program/program.dart';

@LazySingleton(as: ProgramsBloc, env: [Environment.test])
class MockProgramsBloc extends Mock implements ProgramsBloc;

@LazySingleton(as: ProgramDetailBloc, env: [Environment.test])
class MockProgramDetailBloc extends Mock implements ProgramDetailBloc;

@LazySingleton(as: ProgramMutationBloc, env: [Environment.test])
class MockProgramMutationBloc extends Mock implements ProgramMutationBloc;
