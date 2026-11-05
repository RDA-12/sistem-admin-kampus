import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';

@LazySingleton(as: IAcademicYearRepository, env: [Environment.test])
class MockAcademicYearRepository extends Mock
    implements IAcademicYearRepository;

@LazySingleton(as: IAcademicTermRepository, env: [Environment.test])
class MockAcademicTermRepository extends Mock
    implements IAcademicTermRepository;

@LazySingleton(as: IAcademicCalendarEventRepository, env: [Environment.test])
class MockAcademicCalendarEventRepository extends Mock
    implements IAcademicCalendarEventRepository;

@LazySingleton(as: WatchAcademicYearsUseCase, env: [Environment.test])
class MockWatchAcademicYearsUseCase extends Mock
    implements WatchAcademicYearsUseCase;

@LazySingleton(as: WatchSingleAcademicYearUseCase, env: [Environment.test])
class MockWatchSingleAcademicYearUseCase extends Mock
    implements WatchSingleAcademicYearUseCase;

@LazySingleton(as: CreateAcademicYearUseCase, env: [Environment.test])
class MockCreateAcademicYearUseCase extends Mock
    implements CreateAcademicYearUseCase;

@LazySingleton(as: UpdateAcademicYearUseCase, env: [Environment.test])
class MockUpdateAcademicYearUseCase extends Mock
    implements UpdateAcademicYearUseCase;

@LazySingleton(as: DeleteAcademicYearUseCase, env: [Environment.test])
class MockDeleteAcademicYearUseCase extends Mock
    implements DeleteAcademicYearUseCase;

@LazySingleton(as: WatchAcademicTermsUseCase, env: [Environment.test])
class MockWatchAcademicTermsUseCase extends Mock
    implements WatchAcademicTermsUseCase;

@LazySingleton(as: WatchSingleAcademicTermUseCase, env: [Environment.test])
class MockWatchSingleAcademicTermUseCase extends Mock
    implements WatchSingleAcademicTermUseCase;

@LazySingleton(as: CreateAcademicTermUseCase, env: [Environment.test])
class MockCreateAcademicTermUseCase extends Mock
    implements CreateAcademicTermUseCase;

@LazySingleton(as: UpdateAcademicTermUseCase, env: [Environment.test])
class MockUpdateAcademicTermUseCase extends Mock
    implements UpdateAcademicTermUseCase;

@LazySingleton(as: DeleteAcademicTermUseCase, env: [Environment.test])
class MockDeleteAcademicTermUseCase extends Mock
    implements DeleteAcademicTermUseCase;

@LazySingleton(
  as: WatchAcademicCalendarEventsUseCase,
  env: [Environment.test],
)
class MockWatchAcademicCalendarEventsUseCase extends Mock
    implements WatchAcademicCalendarEventsUseCase;

@LazySingleton(
  as: CreateAcademicCalendarEventUseCase,
  env: [Environment.test],
)
class MockCreateAcademicCalendarEventUseCase extends Mock
    implements CreateAcademicCalendarEventUseCase;

@LazySingleton(
  as: UpdateAcademicCalendarEventUseCase,
  env: [Environment.test],
)
class MockUpdateAcademicCalendarEventUseCase extends Mock
    implements UpdateAcademicCalendarEventUseCase;

@LazySingleton(
  as: DeleteAcademicCalendarEventUseCase,
  env: [Environment.test],
)
class MockDeleteAcademicCalendarEventUseCase extends Mock
    implements DeleteAcademicCalendarEventUseCase;

final academicYearsMock = List<AcademicYear>.generate(
  5,
  (index) => AcademicYear(
    id: '$index',
    name: '202$index/202${index + 1}',
    startDate: DateTime(2020 + index, 9),
    endDate: DateTime(2021 + index, 8, 31),
  ),
);

final AcademicYear academicYearMock = academicYearsMock.first;

final academicTermsMock = List<AcademicTerm>.generate(
  3,
  (index) => AcademicTerm(
    id: '$index',
    academicYearId: academicYearMock.id,
    name: 'Semester ${index + 1}',
    startDate: DateTime(2020, index * 4 + 1),
    endDate: DateTime(2020, index * 4 + 4),
  ),
);

final AcademicTerm academicTermMock = academicTermsMock.first;
