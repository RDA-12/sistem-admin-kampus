import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/academic_calendar/domain/filters/academic_term_filter.dart';
import 'package:sistem_admin/academic_calendar/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Use case to watch for [AcademicTerm] data changes
@LazySingleton(env: [Environment.prod])
class WatchAcademicTermsUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<AcademicTermFilter?, List<AcademicTerm>> {
  /// Creates new [WatchAcademicTermsUseCase]
  new({required this._academicTermRepository});

  final IAcademicTermRepository _academicTermRepository;

  @override
  Stream<AppResult<List<AcademicTerm>>> call([AcademicTermFilter? params]) {
    logDebug(
      'start watching academic terms',
      extra: params != null ? {'filter': params} : null,
    );
    return _academicTermRepository.watch(params);
  }
}
