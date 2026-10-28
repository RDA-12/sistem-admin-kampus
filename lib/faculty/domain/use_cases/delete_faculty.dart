import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/domain/entities.dart';
import 'package:sistem_admin/faculty/domain/repository.dart';

/// Use case for deleting a Faculty
@LazySingleton(env: [Environment.prod])
class DeleteFacultyUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<Faculty, Null> {
  /// Creates new [DeleteFacultyUseCase]
  new({required this._facultyRepository});

  final IFacultyRepository _facultyRepository;

  @override
  Future<AppResult<Null>> call(Faculty params) async {
    logDebug('start deleting faculty', extra: {'id': params.id});
    final result = await _facultyRepository.delete(params.id);
    switch (result) {
      case AppSuccess():
        logDebug('faculty deleted');
        return AppResult.success(null);
      case AppFailure<Null>(:final exception):
        logDebug('faculty deletion failed');
        return AppResult.failure(exception);
    }
  }
}
