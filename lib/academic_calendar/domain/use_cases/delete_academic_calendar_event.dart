import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/academic_calendar/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Use case for deleting an [AcademicCalendarEvent]
@LazySingleton(env: [Environment.prod])
class DeleteAcademicCalendarEventUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<AcademicCalendarEvent, Null> {
  /// Creates new [DeleteAcademicCalendarEventUseCase]
  new({required this._academicCalendarEventRepository});

  final IAcademicCalendarEventRepository _academicCalendarEventRepository;

  @override
  Future<AppResult<Null>> call(AcademicCalendarEvent params) async {
    logDebug(
      'start deleting academic calendar event',
      extra: {'id': params.id},
    );
    final result = await _academicCalendarEventRepository.delete(params.id);
    switch (result) {
      case AppSuccess():
        logDebug('academic calendar event deleted');
        return AppResult.success(null);
      case AppFailure<Null>(:final exception):
        logDebug('academic calendar event deletion failed');
        return AppResult.failure(exception);
    }
  }
}
