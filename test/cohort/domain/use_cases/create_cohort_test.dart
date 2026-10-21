import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';
import '../mocks.dart';

void main() {
  final params = CreateCohortParams(
    name: cohortMock.name,
    entryYear: cohortMock.entryYear,
  );
  late ICohortRepository repositoryMock;
  late CreateCohortUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<ICohortRepository>();
    when(() => repositoryMock.save(params))
        .thenAnswer((_) async => AppResult.success(cohortMock));

    useCase = CreateCohortUseCase(
      cohortRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('CreateCohortUseCase', () {
    test(
      'returns failure when ICohortRepository.save fails',
      () async {
        when(() => repositoryMock.save(params)).thenAnswer(
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
      verify(() => repositoryMock.save(params)).called(1);
    });
  });
}
