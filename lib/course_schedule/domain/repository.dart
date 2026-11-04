import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/domain/entities.dart';
import 'package:sistem_admin/course_schedule/domain/use_cases/use_cases.dart';

/// Manage data on [CourseSchedule]
abstract interface class ICourseScheduleRepository
    extends
        BaseRepository<
          CourseSchedule,
          CreateCourseScheduleParams,
          UpdateCourseScheduleParams
        > {
  /// Watch for [CourseSchedule] data changes for specific
  /// [academicYearId]
  Stream<AppResult<List<CourseSchedule>>> watchByAcademicYear(
    String academicYearId,
  );

  /// Watch for [CourseSchedule] data changes for specific [cohortId]
  Stream<AppResult<List<CourseSchedule>>> watchByCohort(
    String cohortId,
  );
}
