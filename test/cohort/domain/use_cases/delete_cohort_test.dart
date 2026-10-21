import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';
import '../mocks.dart';

void main() {
  late ICohortRepository repositoryMock;
  late DeleteCohortUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<ICohortRepository>();
    when(() => repositoryMock.delete(cohortMock.id))
        .thenAnswer((_) async => AppResult.success(null));

    useCase = DeleteCohortUseCase(
      cohortRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('DeleteCohortUseCase', () {
    test(
      'returns failure when ICohortRepository.delete fails',
      () async {
        when(() => repositoryMock.delete(cohortMock.id)).thenAnswer(
          (_) async => AppResult<Null>.failure(
            AppException.test(),
          ),
        );

        final result = await useCase(cohortMock);

        expect(
          result,
          isA<AppFailure<Null>>().having(
            (e) => e.exception,
            'exception',
            AppException.test(),
          ),
        );
      },
    );

    test('returns correct null when all operations success', () async {
      final result = await useCase(cohortMock);

      expect(result, AppResult.success(null));
      verify(() => repositoryMock.delete(cohortMock.id)).called(1);
    });
  });
}
