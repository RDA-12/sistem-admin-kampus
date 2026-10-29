import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';

void main() {
  final events = List.generate(
    2,
    (index) => AcademicCalendarEvent(
      id: '$index',
      academicYearId: 'year_1',
      name: 'Event ${index + 1}',
      type: AcademicCalendarEventType.lectures,
      start: EventDateTime(
        date: DateTime(2025, 9, 10 + index),
        time: const Time(hour: 8, minute: 0),
      ),
      end: EventDateTime(
        date: DateTime(2025, 9, 10 + index),
        time: const Time(hour: 12, minute: 0),
      ),
    ),
  );

  late IAcademicCalendarEventRepository repositoryMock;
  late WatchAcademicCalendarEventsByYearUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<IAcademicCalendarEventRepository>();
    when(() => repositoryMock.watchByAcademicYear('year_1'))
        .thenAnswer((_) => Stream.value(AppResult.success(events)));

    useCase = WatchAcademicCalendarEventsByYearUseCase(
      academicCalendarEventRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('WatchAcademicCalendarEventsByYearUseCase', () {
    test(
      'emits correct list of AcademicCalendarEvent for academic year',
      () async {
        final stream = useCase('year_1');

        expect(stream, emits(AppResult.success(events)));
      },
    );

    test('emits failure when repo emits failure', () {
      when(() => repositoryMock.watchByAcademicYear('year_1')).thenAnswer(
        (_) => Stream.value(
          AppFailure<List<AcademicCalendarEvent>>(
            exception: AppException.test(),
          ),
        ),
      );

      final stream = useCase('year_1');

      expect(
        stream,
        emits(
          AppFailure<List<AcademicCalendarEvent>>(
            exception: AppException.test(),
          ),
        ),
      );
    });
  });
}
