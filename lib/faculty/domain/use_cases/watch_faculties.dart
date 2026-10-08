import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/domain/entities.dart';
import 'package:sistem_admin/faculty/domain/repository.dart';

/// Use case to watch for [Faculty] data changes
class WatchFacultiesUseCase implements StreamBaseUseCase<Null, List<Faculty>> {
  /// Creates new [WatchFacultiesUseCase]
  new({required this._facultyRepository});

  final IFacultyRepository _facultyRepository;

  @override
  Stream<AppResult<List<Faculty>>> call(Null params) {
    return _facultyRepository.watch();
  }
}
