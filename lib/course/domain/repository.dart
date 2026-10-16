import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/domain/entities.dart';
import 'package:sistem_admin/course/domain/use_cases/use_cases.dart';

/// Manage data on [Course]
abstract interface class ICourseRepository
    extends BaseRepository<Course, CreateCourseParams, UpdateCourseParams> {
  /// Watch for [Course] data changes for specific [programId]
  Stream<AppResult<List<Course>>> watchByProgram(String programId);
}
