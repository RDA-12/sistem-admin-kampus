import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/lecturer/domain/entities.dart';
import 'package:sistem_admin/lecturer/domain/repository.dart';

/// Use case for watching single [Lecturer] data changes
@LazySingleton(env: [Environment.prod])
class WatchSingleLecturerUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<String, Lecturer> {
  /// Creates new [WatchSingleLecturerUseCase]
  new({required this._lecturerRepository});

  final ILecturerRepository _lecturerRepository;

  @override
  Stream<AppResult<Lecturer>> call(String params) {
    logDebug('start watching single lecturer', extra: {'id': params});
    return _lecturerRepository.watchSingle(params);
  }
}
