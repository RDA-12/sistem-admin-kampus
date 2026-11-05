import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/domain/entities.dart';
import 'package:sistem_admin/course/domain/filters/course_filter.dart';
import 'package:sistem_admin/course/domain/use_cases/use_cases.dart';

/// Manage data on [Course]
abstract interface class ICourseRepository
    extends
        BaseRepository<
          Course,
          CreateCourseParams,
          UpdateCourseParams,
          CourseFilter
        >;
