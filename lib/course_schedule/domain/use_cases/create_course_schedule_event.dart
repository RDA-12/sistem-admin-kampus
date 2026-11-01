import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/domain/entities.dart';
import 'package:sistem_admin/course_schedule/domain/repository.dart';

/// Params for creating a [CourseScheduleEvent]
final class CreateCourseScheduleEventParams extends Equatable {
  /// Creates new [CreateCourseScheduleEventParams]
  const new({
    required this.academicYearId,
    required this.name,
    required this.start,
    required this.end,
    required this.courseDetail,
    this.recurrence = const [],
  });

  /// ID of the parent academic year
  final String academicYearId;

  /// Name of the event
  final String name;

  /// When the event starts
  final EventDateTime start;

  /// When the event ends
  final EventDateTime end;

  /// Recurrence rules (RFC5545)
  final List<String> recurrence;

  /// Detail of course for this event
  final CourseScheduleEventDetail courseDetail;

  @override
  List<Object?> get props => [
    academicYearId,
    name,
    start,
    end,
    recurrence,
    courseDetail,
  ];
}

/// Use case for creating new [CourseScheduleEvent]
@LazySingleton(env: [Environment.prod])
class CreateCourseScheduleEventUseCase
    with AppLoggerMixin
    implements
        FutureBaseUseCase<
          CreateCourseScheduleEventParams,
          CourseScheduleEvent
        > {
  /// Creates new [CreateCourseScheduleEventUseCase]
  new({
    required this._courseScheduleEventRepository,
    required this._academicYearRepository,
  });

  final IAcademicYearRepository _academicYearRepository;
  final ICourseScheduleEventRepository _courseScheduleEventRepository;

  @override
  Future<AppResult<CourseScheduleEvent>> call(
    CreateCourseScheduleEventParams params,
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
      'start checking whether event can be added',
      extra: {
        'startDate': params.start.date,
        'endDate': params.end.date,
      },
    );
    final calendar = AcademicCalendar(year: year);
    final allowedResult = calendar.canAddEvent(
      startDate: params.start.date,
      endDate: params.end.date,
    );
    switch (allowedResult) {
      case AppFailure<Null>(:final exception):
        logDebug('failed to add new event: outside academic year');
        return AppResult.failure(exception);
      case AppSuccess<Null>():
    }

    logDebug(
      'new event allowed. start creating course schedule event',
      extra: {
        'academicYearId': params.academicYearId,
        'name': params.name,
        'start': params.start,
        'end': params.end,
        'courseDetail': params.courseDetail,
      },
    );
    final result = await _courseScheduleEventRepository.save(params);
    switch (result) {
      case AppSuccess(:final data):
        logDebug('course schedule event created');
        return AppResult.success(data);
      case AppFailure<CourseScheduleEvent>(:final exception):
        logDebug('course schedule event creation failed');
        return AppResult.failure(exception);
    }
  }
}
