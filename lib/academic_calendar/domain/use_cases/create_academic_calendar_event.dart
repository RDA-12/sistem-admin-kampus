import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/academic_calendar/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Params for creating an [AcademicCalendarEvent]
final class CreateAcademicCalendarEventParams extends Equatable {
  /// Creates new [CreateAcademicCalendarEventParams]
  const new({
    required this.academicYearId,
    required this.name,
    required this.type,
    required this.start,
    required this.end,
    this.recurrence = const [],
  });

  /// ID of the parent academic year
  final String academicYearId;

  /// Name of the event
  final String name;

  /// Type of the event
  final AcademicCalendarEventType type;

  /// When the event start
  final EventDateTime start;

  /// When the event end
  final EventDateTime end;

  /// Recurrence rules (RFC5545)
  final List<String> recurrence;

  @override
  List<Object?> get props => [
    academicYearId,
    name,
    type,
    start,
    end,
    recurrence,
  ];
}

/// Use case for creating new [AcademicCalendarEvent]
@LazySingleton(env: [Environment.prod])
class CreateAcademicCalendarEventUseCase
    with AppLoggerMixin
    implements
        FutureBaseUseCase<
          CreateAcademicCalendarEventParams,
          AcademicCalendarEvent
        > {
  /// Creates new [CreateAcademicCalendarEventUseCase]
  new({
    required this._academicCalendarEventRepository,
    required this._academicYearRepository,
  });

  final IAcademicYearRepository _academicYearRepository;
  final IAcademicCalendarEventRepository _academicCalendarEventRepository;

  /// Run creating new [AcademicCalendarEvent]
  @override
  Future<AppResult<AcademicCalendarEvent>> call(
    CreateAcademicCalendarEventParams params,
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
      'new event allowed. start creating academic calendar event',
      extra: {
        'academicYearId': params.academicYearId,
        'name': params.name,
        'type': params.type,
        'start': params.start,
        'end': params.end,
      },
    );
    final result = await _academicCalendarEventRepository.save(params);
    switch (result) {
      case AppSuccess(:final data):
        logDebug('academic calendar event created');
        return AppResult.success(data);
      case AppFailure<AcademicCalendarEvent>(:final exception):
        logDebug('academic calendar event creation failed');
        return AppResult.failure(exception);
    }
  }
}
