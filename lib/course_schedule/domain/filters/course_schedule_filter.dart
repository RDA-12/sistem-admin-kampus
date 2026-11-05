import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course_schedule/domain/entities.dart';

/// Filter criteria for querying [CourseSchedule]
final class CourseScheduleFilter extends Filter {
  /// Creates new [CourseScheduleFilter]
  const new({
    this.academicYearId,
    this.cohortId,
    this.termId,
    this.programId,
  });

  /// Filter by academic year ID
  final String? academicYearId;

  /// Filter by cohort ID
  final String? cohortId;

  /// Filter by term ID
  final String? termId;

  /// Filter by program ID
  final String? programId;

  @override
  List<Object?> get props => [
    academicYearId,
    cohortId,
    termId,
    programId,
  ];
}
