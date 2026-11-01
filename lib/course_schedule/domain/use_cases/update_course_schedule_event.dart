import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/domain/entities.dart';
import 'package:sistem_admin/course_schedule/domain/repository.dart';

/// Params for updating a [CourseScheduleEvent]
final class UpdateCourseScheduleEventParams extends Equatable {
  /// Creates new [UpdateCourseScheduleEventParams]
  const new(
    this.event, {
    this.academicYearId,
    this.name,
    this.start,
    this.end,
    this.recurrence,
    this.courseDetail,
    this.cohortId,
    this.courseId,
    this.programId,
    this.lecturerId,
    this.roomId,
  });

  /// Event that will be updated
  final CourseScheduleEvent event;

  /// Updated parent academic year ID
  final String? academicYearId;

  /// Updated name
  final String? name;

  /// Updated start date and time
  final EventDateTime? start;

  /// Updated end date and time
  final EventDateTime? end;

  /// Updated recurrence rules
  final List<String>? recurrence;

  /// Updated course detail
  final CourseScheduleEventDetail? courseDetail;

  /// Updated cohort ID
  final String? cohortId;

  /// Updated course ID
  final String? courseId;

  /// Updated program ID
  final String? programId;

  /// Updated lecturer ID
  final String? lecturerId;

  /// Updated room ID
  final String? roomId;

  @override
  List<Object?> get props => [
    event,
    academicYearId,
    name,
    start,
    end,
    recurrence,
    courseDetail,
    cohortId,
    courseId,
    programId,
    lecturerId,
    roomId,
  ];
}

/// Use case for updating a [CourseScheduleEvent]
@LazySingleton(env: [Environment.prod])
class UpdateCourseScheduleEventUseCase
    with AppLoggerMixin
    implements
        FutureBaseUseCase<
          UpdateCourseScheduleEventParams,
          CourseScheduleEvent
        > {
  /// Creates new [UpdateCourseScheduleEventUseCase]
  new({
    required this._courseScheduleEventRepository,
    required this._academicYearRepository,
  });

  final IAcademicYearRepository _academicYearRepository;
  final ICourseScheduleEventRepository _courseScheduleEventRepository;

  @override
  Future<AppResult<CourseScheduleEvent>> call(
    UpdateCourseScheduleEventParams params,
  ) async {
    final academicYearId = params.academicYearId ?? params.event.academicYearId;
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

    final startDate = params.start?.date ?? params.event.start.date;
    final endDate = params.end?.date ?? params.event.end.date;

    logDebug(
      'start checking whether event can be updated',
      extra: {
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    final calendar = AcademicCalendar(year: year);
    final allowedResult = calendar.canUpdateEvent(
      startDate: startDate,
      endDate: endDate,
    );
    switch (allowedResult) {
      case AppFailure<Null>(:final exception):
        logDebug('failed to update event: outside academic year');
        return AppResult.failure(exception);
      case AppSuccess<Null>():
    }

    logDebug(
      'event update allowed. start updating course schedule event',
      extra: {
        'id': params.event.id,
        'academicYearId': params.academicYearId,
        'name': params.name,
        'start': params.start,
        'end': params.end,
        'courseDetail': params.courseDetail,
      },
    );
    final result = await _courseScheduleEventRepository.update(
      params.event.id,
      args: params,
    );
    switch (result) {
      case AppSuccess(:final data):
        logDebug('course schedule event updated');
        return AppResult.success(data);
      case AppFailure<CourseScheduleEvent>(:final exception):
        logDebug('course schedule event update failed');
        return AppResult.failure(exception);
    }
  }
}
