import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/lecturer/domain/entities.dart';
import 'package:sistem_admin/lecturer/domain/repository.dart';

/// Use case for deleting a Lecturer
@LazySingleton(env: [Environment.prod])
class DeleteLecturerUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<Lecturer, Null> {
  /// Creates new [DeleteLecturerUseCase]
  new({required this._lecturerRepository});

  final ILecturerRepository _lecturerRepository;

  @override
  Future<AppResult<Null>> call(Lecturer params) async {
    logDebug('start deleting lecturer', extra: {'id': params.id});
    final result = await _lecturerRepository.delete(params.id);
    switch (result) {
      case AppSuccess():
        logDebug('lecturer deleted');
        return AppResult.success(null);
      case AppFailure<Null>(:final exception):
        logDebug('lecturer deletion failed');
        return AppResult.failure(exception);
    }
  }
}
