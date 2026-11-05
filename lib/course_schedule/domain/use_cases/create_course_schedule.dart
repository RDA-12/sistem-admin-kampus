import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/domain/entities.dart';
import 'package:sistem_admin/course_schedule/domain/filters/course_schedule_filter.dart';
import 'package:sistem_admin/course_schedule/domain/repository.dart';

/// Params for creating a [CourseSchedule]
final class CreateCourseScheduleParams extends Equatable {
  /// Creates new [CreateCourseScheduleParams]
  const new({
    required this.academicYearId,
    required this.termId,
    required this.programId,
    required this.name,
    required this.start,
    required this.duration,
    required this.cohortId,
    required this.courseId,
    required this.lecturerId,
    required this.roomId,
  });

  /// ID of the parent academic year
  final String academicYearId;

  /// ID of the term
  final String termId;

  /// ID of the program
  final String programId;

  /// Name of the course schedule
  final String name;

  /// When the schedule starts
  final DateTime start;

  /// Duration of the course
  final Duration duration;

  /// ID of the cohort
  final String cohortId;

  /// ID of the course
  final String courseId;

  /// ID of the lecturer
  final String lecturerId;

  /// ID of the room
  final String roomId;

  @override
  List<Object?> get props => [
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

/// Use case for creating new [CourseSchedule]
@LazySingleton(env: [Environment.prod])
class CreateCourseScheduleUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<CreateCourseScheduleParams, CourseSchedule> {
  /// Creates new [CreateCourseScheduleUseCase]
  new({
    required this._academicYearRepository,
    required this._courseScheduleRepository,
  });

  final IAcademicYearRepository _academicYearRepository;
  final ICourseScheduleRepository _courseScheduleRepository;

  @override
  Future<AppResult<CourseSchedule>> call(
    CreateCourseScheduleParams params,
  ) async {
    logDebug(
      'start getting academic year',
      extra: {'academicYearId': params.academicYearId},
    );
    late final AcademicYear year;
    final academicYearResult = await _academicYearRepository
        .watchSingle(params.academicYearId)
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

    logDebug(
      'start checking whether course schedule can be added',
      extra: {
        'start': params.start,
        'cohortId': params.cohortId,
        'courseId': params.courseId,
        'lecturerId': params.lecturerId,
        'roomId': params.roomId,
      },
    );
    final calendar = CourseCalendar(
      academicCalendar: AcademicCalendar(year: year),
      schedules: schedules,
    );
    final allowedResult = calendar.canAddSchedule(
      start: params.start,
      cohortId: params.cohortId,
      courseId: params.courseId,
      lecturerId: params.lecturerId,
      roomId: params.roomId,
    );
    switch (allowedResult) {
      case AppFailure<Null>(:final exception):
        logDebug('failed to add course schedule: collision detected');
        return AppResult.failure(exception);
      case AppSuccess<Null>():
    }

    logDebug(
      'course schedule allowed. start creating course schedule',
      extra: {
        'academicYearId': params.academicYearId,
        'termId': params.termId,
        'name': params.name,
      },
    );
    final result = await _courseScheduleRepository.save(params);
    switch (result) {
      case AppSuccess(:final data):
        logDebug('course schedule created');
        return AppResult.success(data);
      case AppFailure<CourseSchedule>(:final exception):
        logDebug('course schedule creation failed');
        return AppResult.failure(exception);
    }
  }
}
