import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';
import '../mocks.dart';

void main() {
  late ICohortRepository repositoryMock;
  late WatchSingleCohortUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<ICohortRepository>();
    when(() => repositoryMock.watchSingle(cohortMock.id))
        .thenAnswer((_) => Stream.value(AppResult.success(cohortMock)));

    useCase = WatchSingleCohortUseCase(
      cohortRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('WatchSingleCohortUseCase', () {
    test('emits correct Cohort', () async {
      final stream = useCase(cohortMock.id);

      expect(stream, emits(AppResult.success(cohortMock)));
    });

    test('emits failure when repo emits failure', () {
      when(() => repositoryMock.watchSingle(cohortMock.id)).thenAnswer(
        (_) => Stream.value(
          AppFailure<Cohort>(exception: AppException.test()),
        ),
      );

      final stream = useCase(cohortMock.id);

      expect(
        stream,
        emits(AppFailure<Cohort>(exception: AppException.test())),
      );
    });
  });
}
