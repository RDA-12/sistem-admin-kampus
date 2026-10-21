import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/cohort/cohort.dart';

@LazySingleton(as: CohortsBloc, env: [Environment.test])
class MockCohortsBloc extends Mock implements CohortsBloc;

@LazySingleton(as: CohortDetailBloc, env: [Environment.test])
class MockCohortDetailBloc extends Mock implements CohortDetailBloc;

@LazySingleton(as: CohortMutationBloc, env: [Environment.test])
class MockCohortMutationBloc extends Mock implements CohortMutationBloc;
