import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/lecturer/domain/entities.dart';
import 'package:sistem_admin/lecturer/domain/repository.dart';

/// Use case to watch for [Lecturer] data changes
@LazySingleton(env: [Environment.prod])
class WatchLecturersUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<Null, List<Lecturer>> {
  /// Creates new [WatchLecturersUseCase]
  new({required this._lecturerRepository});

  final ILecturerRepository _lecturerRepository;

  @override
  Stream<AppResult<List<Lecturer>>> call(Null params) {
    logDebug('start watching lecturers');
    return _lecturerRepository.watch();
  }
}
