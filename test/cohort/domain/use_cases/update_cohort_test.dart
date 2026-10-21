import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';
import '../mocks.dart';

void main() {
  const params = UpdateCohortParams(
    cohortMock,
    name: 'Cohort 2026',
    entryYear: 2026,
  );
  late ICohortRepository repositoryMock;
  late UpdateCohortUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<ICohortRepository>();
    when(() => repositoryMock.update(cohortMock.id, args: params))
        .thenAnswer((_) async => AppResult.success(cohortMock));

    useCase = UpdateCohortUseCase(
      cohortRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('UpdateCohortUseCase', () {
    test(
      'returns failure when ICohortRepository.update fails',
      () async {
        when(
          () => repositoryMock.update(cohortMock.id, args: params),
        ).thenAnswer(
          (_) async => AppResult<Cohort>.failure(
            AppException.test(),
          ),
        );

        final result = await useCase(params);

        expect(
          result,
          isA<AppFailure<Cohort>>().having(
            (e) => e.exception,
            'exception',
            AppException.test(),
          ),
        );
      },
    );

    test('returns correct Cohort when all operations success', () async {
      final result = await useCase(params);

      expect(result, AppResult.success(cohortMock));
      verify(
        () => repositoryMock.update(cohortMock.id, args: params),
      ).called(1);
    });
  });
}
