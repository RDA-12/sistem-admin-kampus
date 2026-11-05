import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/domain/entities.dart';
import 'package:sistem_admin/course_schedule/domain/filters/course_schedule_filter.dart';
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
    required this._academicYearRepository,
    required this._courseScheduleRepository,
  });

  final IAcademicYearRepository _academicYearRepository;
  final ICourseScheduleRepository _courseScheduleRepository;

  @override
  Future<AppResult<CourseSchedule>> call(
    UpdateCourseScheduleParams params,
  ) async {
    final academicYearId =
        params.academicYearId ?? params.courseSchedule.academicYearId;
    logDebug(
      'start getting academic year',
      extra: {'academicYearId': academicYearId},
    );
    late final AcademicYear year;
    final academicYearResult = await _academicYearRepository
        .watchSingle(academicYearId)
        .first;
    switch (academicYearResult) {
      case AppFailure<AcademicYear>(:final exception):
        logDebug('failed to get academic year');
        return AppResult.failure(exception);
      case AppSuccess<AcademicYear>(:final data):
        year = data;
    }

    logDebug(
      'start getting existing schedules from year',
      extra: {'academicYearId': year.id},
    );
    late final List<CourseSchedule> schedules;
    final schedulesResult = await _courseScheduleRepository
        .watch(CourseScheduleFilter(academicYearId: year.id))
        .first;
    switch (schedulesResult) {
      case AppFailure<List<CourseSchedule>>(:final exception):
        logDebug('failed to get course schedules');
        return AppResult.failure(exception);
      case AppSuccess<List<CourseSchedule>>(:final data):
        schedules = data;
    }

    final start = params.start ?? params.courseSchedule.start;
    final cohortId = params.cohortId ?? params.courseSchedule.cohortId;
    final courseId = params.courseId ?? params.courseSchedule.courseId;
    final lecturerId = params.lecturerId ?? params.courseSchedule.lecturerId;
    final roomId = params.roomId ?? params.courseSchedule.roomId;

    logDebug(
      'start checking whether course schedule can be updated',
      extra: {
        'id': params.courseSchedule.id,
        'start': start,
        'cohortId': cohortId,
        'courseId': courseId,
        'lecturerId': lecturerId,
        'roomId': roomId,
      },
    );
    final calendar = CourseCalendar(
      academicCalendar: AcademicCalendar(year: year),
      schedules: schedules,
    );
    final allowedResult = calendar.canUpdateSchedule(
      scheduleId: params.courseSchedule.id,
      start: start,
      cohortId: cohortId,
      courseId: courseId,
      lecturerId: lecturerId,
      roomId: roomId,
    );
    switch (allowedResult) {
      case AppFailure<Null>(:final exception):
        logDebug('failed to update course schedule: collision detected');
        return AppResult.failure(exception);
      case AppSuccess<Null>():
    }

    logDebug(
      'course schedule update allowed. start updating course schedule',
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
