import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/domain/entities.dart';
import 'package:sistem_admin/program/domain/repository.dart';

/// Params for updating a [Program]
final class UpdateProgramParams extends Equatable {
  /// Creates new [UpdateProgramParams]
  const new(this.program, {required this.name});

  /// Program that will be updated
  final Program program;

  /// Updated name
  final String? name;

  @override
  List<Object?> get props => [program, name];
}

/// Use case for updating a [Program]
@LazySingleton(env: [Environment.prod])
class UpdateProgramUseCase
    implements FutureBaseUseCase<UpdateProgramParams, Program> {
  /// Creates new [UpdateProgramUseCase]
  new({required this._programRepository});

  final IProgramRepository _programRepository;

  @override
  Future<AppResult<Program>> call(UpdateProgramParams params) {
    return _programRepository.update(params.program.id, args: params);
  }
}
