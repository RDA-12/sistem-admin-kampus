import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/domain/entities.dart';

/// Manage data on [Faculty]
abstract interface class IFacultyRepository {
  /// Save new [Faculty] with [name]
  Future<AppResult<Faculty>> save({required String name});
}
