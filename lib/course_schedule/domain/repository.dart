import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course_schedule/domain/entities.dart';
import 'package:sistem_admin/course_schedule/domain/filters/course_schedule_filter.dart';
import 'package:sistem_admin/course_schedule/domain/use_cases/use_cases.dart';

/// Manage data on [CourseSchedule]
abstract interface class ICourseScheduleRepository
    extends
        BaseRepository<
          CourseSchedule,
          CreateCourseScheduleParams,
          UpdateCourseScheduleParams,
          CourseScheduleFilter
        >;
