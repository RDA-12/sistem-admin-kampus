import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/cohort/cohort.dart';

@LazySingleton(as: ICohortRepository, env: [Environment.test])
class MockCohortRepository extends Mock implements ICohortRepository;

@LazySingleton(as: WatchCohortsUseCase, env: [Environment.test])
class MockWatchCohortsUseCase extends Mock implements WatchCohortsUseCase;

@LazySingleton(as: WatchSingleCohortUseCase, env: [Environment.test])
class MockWatchSingleCohortUseCase extends Mock
    implements WatchSingleCohortUseCase;

@LazySingleton(as: CreateCohortUseCase, env: [Environment.test])
class MockCreateCohortUseCase extends Mock implements CreateCohortUseCase;

@LazySingleton(as: UpdateCohortUseCase, env: [Environment.test])
class MockUpdateCohortUseCase extends Mock implements UpdateCohortUseCase;

@LazySingleton(as: DeleteCohortUseCase, env: [Environment.test])
class MockDeleteCohortUseCase extends Mock implements DeleteCohortUseCase;

final cohortsMock = List<Cohort>.generate(
  5,
  (index) => Cohort(
    id: '$index',
    name: 'Cohort 202$index',
    entryYear: 2020 + index,
  ),
);

const cohortMock = Cohort(
  id: 'id',
  name: 'Cohort 2025',
  entryYear: 2025,
);
