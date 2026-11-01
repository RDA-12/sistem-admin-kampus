import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/domain/entities.dart';
import 'package:sistem_admin/course_schedule/domain/use_cases/use_cases.dart';

/// Manage data on [CourseScheduleEvent]
abstract interface class ICourseScheduleEventRepository
    extends
        BaseRepository<
          CourseScheduleEvent,
          CreateCourseScheduleEventParams,
          UpdateCourseScheduleEventParams
        > {
  /// Watch for [CourseScheduleEvent] data changes for specific
  /// [academicYearId]
  Stream<AppResult<List<CourseScheduleEvent>>> watchByAcademicYear(
    String academicYearId,
  );

  /// Watch for [CourseScheduleEvent] data changes for specific [cohortId]
  Stream<AppResult<List<CourseScheduleEvent>>> watchByCohort(
    String cohortId,
  );
}
