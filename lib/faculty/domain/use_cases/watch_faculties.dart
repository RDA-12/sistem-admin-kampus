import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/domain/entities.dart';
import 'package:sistem_admin/faculty/domain/repository.dart';

/// Use case to watch for [Faculty] data changes
@LazySingleton(env: [Environment.prod])
class WatchFacultiesUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<Null, List<Faculty>> {
  /// Creates new [WatchFacultiesUseCase]
  new({required this._facultyRepository});

  final IFacultyRepository _facultyRepository;

  @override
  Stream<AppResult<List<Faculty>>> call(Null params) {
    logDebug('start watching faculties');
    return _facultyRepository.watch();
  }
}
