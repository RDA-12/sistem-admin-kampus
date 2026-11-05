import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

@LazySingleton(as: CourseScheduleMutationBloc, env: [Environment.test])
class MockCourseScheduleMutationBloc extends Mock
    implements CourseScheduleMutationBloc;

@LazySingleton(as: CourseSchedulesBloc, env: [Environment.test])
class MockCourseSchedulesBloc extends Mock implements CourseSchedulesBloc;
