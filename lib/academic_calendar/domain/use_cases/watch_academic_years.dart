import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/academic_calendar/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Use case to watch for [AcademicYear] data changes
@LazySingleton(env: [Environment.prod])
class WatchAcademicYearsUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<Null, List<AcademicYear>> {
  /// Creates new [WatchAcademicYearsUseCase]
  new({required this._academicYearRepository});

  final IAcademicYearRepository _academicYearRepository;

  @override
  Stream<AppResult<List<AcademicYear>>> call(Null params) {
    logDebug('start watching academic years');
    return _academicYearRepository.watch();
  }
}
