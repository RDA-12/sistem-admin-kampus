import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/domain/entities.dart';
import 'package:sistem_admin/faculty/domain/repository.dart';

/// Use case for watching single [Faculty] data changes
@LazySingleton(env: [Environment.prod])
class WatchSingleFacultyUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<String, Faculty> {
  /// Creates new [WatchSingleFacultyUseCase]
  new({required this._facultyRepository});

  final IFacultyRepository _facultyRepository;

  @override
  Stream<AppResult<Faculty>> call(String params) {
    logDebug('start watching single faculty', extra: {'id': params});
    return _facultyRepository.watchSingle(params);
  }
}
