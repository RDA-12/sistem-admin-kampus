import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/domain/entities.dart';
import 'package:sistem_admin/course_schedule/domain/repository.dart';

/// Params for updating a [CourseSchedule]
final class UpdateCourseScheduleParams extends Equatable {
  /// Creates new [UpdateCourseScheduleParams]
  const new(
    this.courseSchedule, {
    this.academicYearId,
    this.termId,
    this.programId,
    this.name,
    this.start,
    this.duration,
    this.cohortId,
    this.courseId,
    this.lecturerId,
    this.roomId,
  });

  /// Course schedule that will be updated
  final CourseSchedule courseSchedule;

  /// Updated parent academic year ID
  final String? academicYearId;

  /// Updated term ID
  final String? termId;

  /// Updated program ID
  final String? programId;

  /// Updated name
  final String? name;

  /// Updated start date and time
  final DateTime? start;

  /// Updated duration
  final Duration? duration;

  /// Updated cohort ID
  final String? cohortId;

  /// Updated course ID
  final String? courseId;

  /// Updated lecturer ID
  final String? lecturerId;

  /// Updated room ID
  final String? roomId;

  @override
  List<Object?> get props => [
    courseSchedule,
    academicYearId,
    termId,
    programId,
    name,
    start,
    duration,
    cohortId,
    courseId,
    lecturerId,
    roomId,
  ];
}

/// Use case for updating a [CourseSchedule]
@LazySingleton(env: [Environment.prod])
class UpdateCourseScheduleUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<UpdateCourseScheduleParams, CourseSchedule> {
  /// Creates new [UpdateCourseScheduleUseCase]
  new({
    required this._courseScheduleRepository,
  });

  final ICourseScheduleRepository _courseScheduleRepository;

  @override
  Future<AppResult<CourseSchedule>> call(
    UpdateCourseScheduleParams params,
  ) async {
    logDebug(
      'start updating course schedule',
      extra: {
        'id': params.courseSchedule.id,
        'academicYearId': params.academicYearId,
        'termId': params.termId,
        'name': params.name,
      },
    );
    final result = await _courseScheduleRepository.update(
      params.courseSchedule.id,
      args: params,
    );
    switch (result) {
      case AppSuccess(:final data):
        logDebug('course schedule updated');
        return AppResult.success(data);
      case AppFailure<CourseSchedule>(:final exception):
        logDebug('course schedule update failed');
        return AppResult.failure(exception);
    }
  }
}
