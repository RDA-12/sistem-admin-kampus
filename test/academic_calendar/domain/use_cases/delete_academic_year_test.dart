import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';

void main() {
  final year = AcademicYear(
    id: 'id',
    name: '2025/2026',
    startDate: DateTime(2025, 9),
    endDate: DateTime(2026, 8, 31),
  );
  late IAcademicYearRepository repositoryMock;
  late DeleteAcademicYearUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<IAcademicYearRepository>();
    when(() => repositoryMock.delete(year.id))
        .thenAnswer((_) async => AppResult.success(null));

    useCase = DeleteAcademicYearUseCase(
      academicYearRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('DeleteAcademicYearUseCase', () {
    test(
      'returns failure when IAcademicYearRepository.delete fails',
      () async {
        when(() => repositoryMock.delete(year.id)).thenAnswer(
          (_) async => AppResult<Null>.failure(
            AppException.test(),
          ),
        );

        final result = await useCase(year);

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
      final result = await useCase(year);

      expect(result, AppResult.success(null));
      verify(() => repositoryMock.delete(year.id)).called(1);
    });
  });
}
