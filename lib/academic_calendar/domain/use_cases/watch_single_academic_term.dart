import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/academic_calendar/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Use case for watching single [AcademicTerm] data changes
@LazySingleton(env: [Environment.prod])
class WatchSingleAcademicTermUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<String, AcademicTerm> {
  /// Creates new [WatchSingleAcademicTermUseCase]
  new({required this._academicTermRepository});

  final IAcademicTermRepository _academicTermRepository;

  @override
  Stream<AppResult<AcademicTerm>> call(String params) {
    logDebug('start watching single academic term', extra: {'id': params});
    return _academicTermRepository.watchSingle(params);
  }
}
