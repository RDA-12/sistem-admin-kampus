import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/academic_calendar/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Use case to watch for [AcademicTerm] data changes for specific academic year
@LazySingleton(env: [Environment.prod])
class WatchAcademicTermsByYearUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<String, List<AcademicTerm>> {
  /// Creates new [WatchAcademicTermsByYearUseCase]
  new({required this._academicTermRepository});

  final IAcademicTermRepository _academicTermRepository;

  @override
  Stream<AppResult<List<AcademicTerm>>> call(String params) {
    logDebug(
      'start watching academic terms by academic year',
      extra: {'academicYearId': params},
    );
    return _academicTermRepository.watchByAcademicYear(params);
  }
}
