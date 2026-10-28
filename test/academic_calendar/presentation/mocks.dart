import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';

@LazySingleton(as: AcademicYearsBloc, env: [Environment.test])
class MockAcademicYearsBloc extends Mock implements AcademicYearsBloc;

@LazySingleton(as: AcademicYearDetailBloc, env: [Environment.test])
class MockAcademicYearDetailBloc extends Mock implements AcademicYearDetailBloc;

@LazySingleton(as: AcademicCalendarMutationBloc, env: [Environment.test])
class MockAcademicCalendarMutationBloc extends Mock
    implements AcademicCalendarMutationBloc;
