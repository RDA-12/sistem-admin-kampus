import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';

void main() {
  final years = List.generate(
    3,
    (index) => AcademicYear(
      id: '$index',
      name: '202$index/202${index + 1}',
      startDate: DateTime(2020 + index, 9),
      endDate: DateTime(2021 + index, 8, 31),
    ),
  );
  late IAcademicYearRepository repositoryMock;
  late WatchAcademicYearsUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<IAcademicYearRepository>();
    when(repositoryMock.watch)
        .thenAnswer((_) => Stream.value(AppResult.success(years)));

    useCase = WatchAcademicYearsUseCase(
      academicYearRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('WatchAcademicYearsUseCase', () {
    test('emits correct list of AcademicYear', () async {
      final stream = useCase(null);

      expect(stream, emits(AppResult.success(years)));
    });

    test('emits failure when repo emits failure', () {
      when(repositoryMock.watch).thenAnswer(
        (_) => Stream.value(
          AppFailure<List<AcademicYear>>(exception: AppException.test()),
        ),
      );

      final stream = useCase(null);

      expect(
        stream,
        emits(AppFailure<List<AcademicYear>>(exception: AppException.test())),
      );
    });
  });
}
