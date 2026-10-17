import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/academic_calendar/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Use case for watching single [AcademicYear] data changes
@LazySingleton(env: [Environment.prod])
class WatchSingleAcademicYearUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<String, AcademicYear> {
  /// Creates new [WatchSingleAcademicYearUseCase]
  new({required this._academicYearRepository});

  final IAcademicYearRepository _academicYearRepository;

  @override
  Stream<AppResult<AcademicYear>> call(String params) {
    logDebug('start watching single academic year', extra: {'id': params});
    return _academicYearRepository.watchSingle(params);
  }
}
