import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/academic_calendar/domain/filters/academic_calendar_event_filter.dart';
import 'package:sistem_admin/academic_calendar/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Use case to watch for [AcademicCalendarEvent] data changes
@LazySingleton(env: [Environment.prod])
class WatchAcademicCalendarEventsUseCase
    with AppLoggerMixin
    implements
        StreamBaseUseCase<
          AcademicCalendarEventFilter?,
          List<AcademicCalendarEvent>
        > {
  /// Creates new [WatchAcademicCalendarEventsUseCase]
  new({required this._academicCalendarEventRepository});

  final IAcademicCalendarEventRepository _academicCalendarEventRepository;

  @override
  Stream<AppResult<List<AcademicCalendarEvent>>> call([
    AcademicCalendarEventFilter? params,
  ]) {
    logDebug(
      'start watching academic calendar events',
      extra: params != null ? {'filter': params} : null,
    );
    return _academicCalendarEventRepository.watch(params);
  }
}
