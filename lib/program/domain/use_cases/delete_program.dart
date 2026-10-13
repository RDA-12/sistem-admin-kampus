import 'package:injectable/injectable.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/domain/entities.dart';
import 'package:sistem_admin/program/domain/repository.dart';

/// Use case for deleting a Program
@LazySingleton(env: [Environment.prod])
class DeleteProgramUseCase implements FutureBaseUseCase<Program, Null> {
  /// Creates new [DeleteProgramUseCase]
  new({required this._programRepository});

  final IProgramRepository _programRepository;

  @override
  Future<AppResult<Null>> call(Program params) {
    return _programRepository.delete(params.id);
  }
}
