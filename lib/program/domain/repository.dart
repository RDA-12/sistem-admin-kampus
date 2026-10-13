import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/domain/entities.dart';
import 'package:sistem_admin/program/domain/use_cases/use_cases.dart';

/// Manage data on [Program]
abstract interface class IProgramRepository
    extends BaseRepository<Program, CreateProgramParams, UpdateProgramParams> {
  /// Watch for [Program] data changes for specific [facultyId]
  Stream<AppResult<List<Program>>> watchByFaculty(String facultyId);
}
