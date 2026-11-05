import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/academic_calendar/domain/filters/academic_calendar_event_filter.dart';
import 'package:sistem_admin/academic_calendar/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Use case to watch for [AcademicCalendarEvent] data changes for specific
/// academic year
@LazySingleton(env: [Environment.prod])
class WatchAcademicCalendarEventsByYearUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<String, List<AcademicCalendarEvent>> {
  /// Creates new [WatchAcademicCalendarEventsByYearUseCase]
  new({required this._academicCalendarEventRepository});

  final IAcademicCalendarEventRepository _academicCalendarEventRepository;

  @override
  Stream<AppResult<List<AcademicCalendarEvent>>> call(String params) {
    logDebug(
      'start watching academic calendar events by academic year',
      extra: {'academicYearId': params},
    );
    return _academicCalendarEventRepository.watch(
      AcademicCalendarEventFilter(academicYearId: params),
    );
  }
}
