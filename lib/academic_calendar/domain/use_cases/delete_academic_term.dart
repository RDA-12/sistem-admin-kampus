import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/academic_calendar/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Use case for deleting an [AcademicTerm]
@LazySingleton(env: [Environment.prod])
class DeleteAcademicTermUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<AcademicTerm, Null> {
  /// Creates new [DeleteAcademicTermUseCase]
  new({required this._academicTermRepository});

  final IAcademicTermRepository _academicTermRepository;

  @override
  Future<AppResult<Null>> call(AcademicTerm params) async {
    logDebug('start deleting academic term', extra: {'id': params.id});
    final result = await _academicTermRepository.delete(params.id);
    switch (result) {
      case AppSuccess():
        logDebug('academic term deleted');
        return AppResult.success(null);
      case AppFailure<Null>(:final exception):
        logDebug('academic term deletion failed');
        return AppResult.failure(exception);
    }
  }
}
