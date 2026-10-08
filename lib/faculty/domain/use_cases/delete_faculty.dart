import 'package:sistem_admin/access_control/access_control.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/domain/entities.dart';
import 'package:sistem_admin/faculty/domain/repository.dart';

/// Use case for deleting a Faculty
class DeleteFacultyUseCase implements FutureBaseUseCase<Faculty, Null> {
  /// Creates new [DeleteFacultyUseCase]
  new({required this._accessControl, required this._facultyRepository});

  final AccessControl _accessControl;
  final IFacultyRepository _facultyRepository;

  @override
  Future<AppResult<Null>> call(Faculty params) async {
    final allowed = await _accessControl.permissionCheck(
      action: .delete,
      resource: .faculty,
    );
    if (!allowed) {
      return AppResult.failure(
        const AppException(
          "current user doesn't have enough permission",
          code: .accessControlCheckFail,
        ),
      );
    }
    return await _facultyRepository.delete(params.id);
  }
}
