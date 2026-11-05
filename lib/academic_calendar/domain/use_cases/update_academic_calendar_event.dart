import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/academic_calendar/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Params for updating an [AcademicCalendarEvent]
final class UpdateAcademicCalendarEventParams extends Equatable {
  /// Creates new [UpdateAcademicCalendarEventParams]
  const new(
    this.event, {
    this.academicYearId,
    this.name,
    this.type,
    this.start,
    this.end,
    this.recurrence,
  });

  /// Event that will be updated
  final AcademicCalendarEvent event;

  /// Updated parent academic year ID
  final String? academicYearId;

  /// Updated name
  final String? name;

  /// Updated type
  final AcademicCalendarEventType? type;

  /// Updated start date and time
  final EventDateTime? start;

  /// Updated end date and time
  final EventDateTime? end;

  /// Updated recurrence rules
  final List<String>? recurrence;

  @override
  List<Object?> get props => [
    event,
    academicYearId,
    name,
    type,
    start,
    end,
    recurrence,
  ];
}

/// Use case for updating an [AcademicCalendarEvent]
@LazySingleton(env: [Environment.prod])
class UpdateAcademicCalendarEventUseCase
    with AppLoggerMixin
    implements
        FutureBaseUseCase<
          UpdateAcademicCalendarEventParams,
          AcademicCalendarEvent
        > {
  /// Creates new [UpdateAcademicCalendarEventUseCase]
  new({
    required this._academicCalendarEventRepository,
    required this._academicYearRepository,
  });

  final IAcademicYearRepository _academicYearRepository;
  final IAcademicCalendarEventRepository _academicCalendarEventRepository;

  @override
  Future<AppResult<AcademicCalendarEvent>> call(
    UpdateAcademicCalendarEventParams params,
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
      'event update allowed. start updating academic calendar event',
      extra: {
        'id': params.event.id,
        'academicYearId': params.academicYearId,
        'name': params.name,
        'type': params.type,
        'start': params.start,
        'end': params.end,
      },
    );
    final result = await _academicCalendarEventRepository.update(
      params.event.id,
      args: params,
    );
    switch (result) {
      case AppSuccess(:final data):
        logDebug('academic calendar event updated');
        return AppResult.success(data);
      case AppFailure<AcademicCalendarEvent>(:final exception):
        logDebug('academic calendar event update failed');
        return AppResult.failure(exception);
    }
  }
}
