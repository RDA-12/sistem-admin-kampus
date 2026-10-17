import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/academic_calendar/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Use case for deleting an [AcademicYear]
@LazySingleton(env: [Environment.prod])
class DeleteAcademicYearUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<AcademicYear, Null> {
  /// Creates new [DeleteAcademicYearUseCase]
  new({required this._academicYearRepository});

  final IAcademicYearRepository _academicYearRepository;

  @override
  Future<AppResult<Null>> call(AcademicYear params) async {
    logDebug('start deleting academic year', extra: {'id': params.id});
    final result = await _academicYearRepository.delete(params.id);
    switch (result) {
      case AppSuccess():
        logDebug('academic year deleted');
        return AppResult.success(null);
      case AppFailure<Null>(:final exception):
        logDebug('academic year deletion failed');
        return AppResult.failure(exception);
    }
  }
}
