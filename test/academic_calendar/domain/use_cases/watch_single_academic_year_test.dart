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
  late WatchSingleAcademicYearUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<IAcademicYearRepository>();
    when(() => repositoryMock.watchSingle('id'))
        .thenAnswer((_) => Stream.value(AppResult.success(year)));

    useCase = WatchSingleAcademicYearUseCase(
      academicYearRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('WatchSingleAcademicYearUseCase', () {
    test('emits correct AcademicYear', () async {
      final stream = useCase('id');

      expect(stream, emits(AppResult.success(year)));
    });

    test('emits failure when repo emits failure', () {
      when(() => repositoryMock.watchSingle('id')).thenAnswer(
        (_) => Stream.value(
          AppFailure<AcademicYear>(exception: AppException.test()),
        ),
      );

      final stream = useCase('id');

      expect(
        stream,
        emits(AppFailure<AcademicYear>(exception: AppException.test())),
      );
    });
  });
}
