import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';

void main() {
  final event = AcademicCalendarEvent(
    id: 'id',
    academicYearId: 'year_1',
    name: 'Kuliah Perdana',
    type: AcademicCalendarEventType.lectures,
    start: EventDateTime(
      date: DateTime(2025, 9),
      time: const Time(hour: 8, minute: 0),
    ),
    end: EventDateTime(
      date: DateTime(2025, 9),
      time: const Time(hour: 10, minute: 0),
    ),
  );

  late IAcademicCalendarEventRepository repositoryMock;
  late DeleteAcademicCalendarEventUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<IAcademicCalendarEventRepository>();
    when(() => repositoryMock.delete(event.id))
        .thenAnswer((_) async => AppResult.success(null));

    useCase = DeleteAcademicCalendarEventUseCase(
      academicCalendarEventRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('DeleteAcademicCalendarEventUseCase', () {
    test(
      'returns failure when IAcademicCalendarEventRepository.delete fails',
      () async {
        when(() => repositoryMock.delete(event.id)).thenAnswer(
          (_) async => AppResult<Null>.failure(
            AppException.test(),
          ),
        );

        final result = await useCase(event);

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
      final result = await useCase(event);

      expect(result, AppResult.success(null));
    });
  });
}
