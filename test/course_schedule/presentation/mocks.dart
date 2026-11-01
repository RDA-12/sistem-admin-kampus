import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

@LazySingleton(as: CourseScheduleEventMutationBloc, env: [Environment.test])
class MockCourseScheduleEventMutationBloc extends Mock
    implements CourseScheduleEventMutationBloc;
