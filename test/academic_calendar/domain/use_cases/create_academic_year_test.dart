import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';

void main() {
  final params = CreateAcademicYearParams(
    name: '2025/2026',
    startDate: DateTime(2025, 9),
    endDate: DateTime(2026, 8, 31),
  );
  final year = AcademicYear(
    id: 'id',
    name: '2025/2026',
    startDate: DateTime(2025, 9),
    endDate: DateTime(2026, 8, 31),
  );
  late IAcademicYearRepository repositoryMock;
  late CreateAcademicYearUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<IAcademicYearRepository>();
    when(() => repositoryMock.save(params))
        .thenAnswer((_) async => AppResult.success(year));

    useCase = CreateAcademicYearUseCase(
      academicYearRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('CreateAcademicYearUseCase', () {
    test(
      'returns failure when IAcademicYearRepository.save fails',
      () async {
        when(() => repositoryMock.save(params)).thenAnswer(
          (_) async => AppResult<AcademicYear>.failure(
            AppException.test(),
          ),
        );

        final result = await useCase(params);

        expect(
          result,
          isA<AppFailure<AcademicYear>>().having(
            (e) => e.exception,
            'exception',
            AppException.test(),
          ),
        );
      },
    );

    test('returns correct AcademicYear when all operations success', () async {
      final result = await useCase(params);

      expect(result, AppResult.success(year));
      verify(() => repositoryMock.save(params)).called(1);
    });
  });
}
