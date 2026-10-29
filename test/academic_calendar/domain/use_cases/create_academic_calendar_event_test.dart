import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';

void main() {
  final year = AcademicYear(
    id: 'year_1',
    name: '2025/2026',
    startDate: DateTime(2025, 9),
    endDate: DateTime(2026, 8, 31),
  );

  final start = EventDateTime(
    date: DateTime(2025, 10),
    time: const Time(hour: 8, minute: 0),
  );
  final end = EventDateTime(
    date: DateTime(2025, 10),
    time: const Time(hour: 10, minute: 0),
  );

  final params = CreateAcademicCalendarEventParams(
    academicYearId: year.id,
    name: 'Kuliah Perdana',
    type: AcademicCalendarEventType.lectures,
    start: start,
    end: end,
    recurrence: const ['RRULE:FREQ=WEEKLY'],
  );

  final event = AcademicCalendarEvent(
    id: 'event_1',
    academicYearId: year.id,
    name: 'Kuliah Perdana',
    type: AcademicCalendarEventType.lectures,
    start: start,
    end: end,
    recurrence: const ['RRULE:FREQ=WEEKLY'],
  );

  late IAcademicYearRepository academicYearRepositoryMock;
  late IAcademicCalendarEventRepository academicCalendarEventRepositoryMock;
  late CreateAcademicCalendarEventUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    academicYearRepositoryMock = getIt<IAcademicYearRepository>();
    academicCalendarEventRepositoryMock =
        getIt<IAcademicCalendarEventRepository>();

    when(() => academicYearRepositoryMock.watchSingle(year.id)).thenAnswer(
      (_) => Stream.value(AppResult.success(year)),
    );
    when(() => academicCalendarEventRepositoryMock.save(params)).thenAnswer(
      (_) async => AppResult.success(event),
    );

    useCase = CreateAcademicCalendarEventUseCase(
      academicYearRepository: academicYearRepositoryMock,
      academicCalendarEventRepository: academicCalendarEventRepositoryMock,
    );
  });

  tearDown(() {
    reset(academicYearRepositoryMock);
    reset(academicCalendarEventRepositoryMock);
  });

  group('CreateAcademicCalendarEventUseCase', () {
    test(
      'returns failure when IAcademicYearRepository.watchSingle fails',
      () async {
        when(() => academicYearRepositoryMock.watchSingle(year.id)).thenAnswer(
          (_) => Stream.value(
            AppFailure<AcademicYear>(exception: AppException.test()),
          ),
        );

        final result = await useCase(params);

        expect(
          result,
          isA<AppFailure<AcademicCalendarEvent>>().having(
            (e) => e.exception,
            'exception',
            AppException.test(),
          ),
        );
      },
    );

    test(
      'returns failure with academicCalendarEventOutsideYear when event date '
      'is outside academic year',
      () async {
        final outsideParams = CreateAcademicCalendarEventParams(
          academicYearId: year.id,
          name: 'Kuliah Perdana',
          type: AcademicCalendarEventType.lectures,
          start: EventDateTime(
            date: DateTime(2025, 8, 31),
            time: const Time(hour: 8, minute: 0),
          ),
          end: end,
        );

        final result = await useCase(outsideParams);

        expect(
          result,
          isA<AppFailure<AcademicCalendarEvent>>().having(
            (e) => e.exception.code,
            'code',
            AppExceptionCode.academicCalendarEventOutsideYear,
          ),
        );
      },
    );

    test(
      'returns failure when IAcademicCalendarEventRepository.save fails',
      () async {
        when(
          () => academicCalendarEventRepositoryMock.save(params),
        ).thenAnswer(
          (_) async => AppResult<AcademicCalendarEvent>.failure(
            AppException.test(),
          ),
        );

        final result = await useCase(params);

        expect(
          result,
          isA<AppFailure<AcademicCalendarEvent>>().having(
            (e) => e.exception,
            'exception',
            AppException.test(),
          ),
        );
      },
    );

    test('returns correct event when all operations succeed', () async {
      final result = await useCase(params);

      expect(result, AppResult.success(event));
    });
  });
}
