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

  final event = AcademicCalendarEvent(
    id: 'event_1',
    academicYearId: year.id,
    name: 'Kuliah Perdana',
    type: AcademicCalendarEventType.lectures,
    start: start,
    end: end,
    recurrence: const ['RRULE:FREQ=WEEKLY'],
  );

  final params = UpdateAcademicCalendarEventParams(
    event,
    name: 'Kuliah Umum',
  );

  late IAcademicYearRepository academicYearRepositoryMock;
  late IAcademicCalendarEventRepository academicCalendarEventRepositoryMock;
  late UpdateAcademicCalendarEventUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    academicYearRepositoryMock = getIt<IAcademicYearRepository>();
    academicCalendarEventRepositoryMock =
        getIt<IAcademicCalendarEventRepository>();

    when(() => academicYearRepositoryMock.watchSingle(year.id)).thenAnswer(
      (_) => Stream.value(AppResult.success(year)),
    );
    when(
      () => academicCalendarEventRepositoryMock.update(
        event.id,
        args: params,
      ),
    ).thenAnswer(
      (_) async => AppResult.success(event),
    );

    useCase = UpdateAcademicCalendarEventUseCase(
      academicYearRepository: academicYearRepositoryMock,
      academicCalendarEventRepository: academicCalendarEventRepositoryMock,
    );
  });

  tearDown(() {
    reset(academicYearRepositoryMock);
    reset(academicCalendarEventRepositoryMock);
  });

  group('UpdateAcademicCalendarEventUseCase', () {
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
      'returns failure with academicCalendarEventOutsideYear when updated date '
      'is outside academic year',
      () async {
        final outsideParams = UpdateAcademicCalendarEventParams(
          event,
          start: EventDateTime(
            date: DateTime(2025, 8, 31),
            time: const Time(hour: 8, minute: 0),
          ),
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
      'returns failure when IAcademicCalendarEventRepository.update fails',
      () async {
        when(
          () => academicCalendarEventRepositoryMock.update(
            event.id,
            args: params,
          ),
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

    test('returns correct updated event when all operations succeed', () async {
      final result = await useCase(params);

      expect(result, AppResult.success(event));
    });

    test(
      'uses params.academicYearId when provided instead of '
      'event.academicYearId',
      () async {
        final year2 = AcademicYear(
          id: 'year_2',
          name: '2026/2027',
          startDate: DateTime(2026, 9),
          endDate: DateTime(2027, 8, 31),
        );
        when(() => academicYearRepositoryMock.watchSingle(year2.id)).thenAnswer(
          (_) => Stream.value(AppResult.success(year2)),
        );

        final changeYearParams = UpdateAcademicCalendarEventParams(
          event,
          academicYearId: year2.id,
          start: EventDateTime(
            date: DateTime(2026, 10),
            time: const Time(hour: 8, minute: 0),
          ),
          end: EventDateTime(
            date: DateTime(2026, 10),
            time: const Time(hour: 10, minute: 0),
          ),
        );

        when(
          () => academicCalendarEventRepositoryMock.update(
            event.id,
            args: changeYearParams,
          ),
        ).thenAnswer((_) async => AppResult.success(event));

        final result = await useCase(changeYearParams);

        expect(result, AppResult.success(event));
        verify(
          () => academicYearRepositoryMock.watchSingle(year2.id),
        ).called(1);
      },
    );
  });
}
