import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';
import '../mocks.dart';

void main() {
  late ICohortRepository repositoryMock;
  late WatchCohortsUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<ICohortRepository>();
    when(repositoryMock.watch)
        .thenAnswer((_) => Stream.value(AppResult.success(cohortsMock)));

    useCase = WatchCohortsUseCase(
      cohortRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('WatchCohortsUseCase', () {
    test('emits correct list of Cohort', () async {
      final stream = useCase(null);

      expect(stream, emits(AppResult.success(cohortsMock)));
    });

    test('emits failure when repo emits failure', () {
      when(repositoryMock.watch).thenAnswer(
        (_) => Stream.value(
          AppFailure<List<Cohort>>(exception: AppException.test()),
        ),
      );

      final stream = useCase(null);

      expect(
        stream,
        emits(AppFailure<List<Cohort>>(exception: AppException.test())),
      );
    });
  });
}
