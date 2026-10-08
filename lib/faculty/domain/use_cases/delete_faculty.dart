import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/domain/entities.dart';
import 'package:sistem_admin/faculty/domain/repository.dart';

/// Use case for deleting a Faculty
class DeleteFacultyUseCase implements FutureBaseUseCase<Faculty, Null> {
  /// Creates new [DeleteFacultyUseCase]
  new({required this._facultyRepository});

  final IFacultyRepository _facultyRepository;

  @override
  Future<AppResult<Null>> call(Faculty params) {
    return _facultyRepository.delete(params.id);
  }
}
