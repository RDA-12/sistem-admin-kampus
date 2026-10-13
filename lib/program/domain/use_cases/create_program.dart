import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/domain/entities.dart';
import 'package:sistem_admin/program/domain/repository.dart';

/// Params for [CreateProgramUseCase]
final class CreateProgramParams extends Equatable {
  /// Creates new [CreateProgramParams]
  const new({required this.facultyId, required this.name});

  /// ID of the parent faculty
  final String facultyId;

  /// Name for the program
  final String name;

  @override
  List<Object?> get props => [facultyId, name];
}

/// Use case for creating new [Program]
@LazySingleton(env: [Environment.prod])
class CreateProgramUseCase
    implements FutureBaseUseCase<CreateProgramParams, Program> {
  /// Creates new [CreateProgramUseCase]
  new({required this._programRepository});

  final IProgramRepository _programRepository;

  /// Run creating new [Program]
  @override
  Future<AppResult<Program>> call(CreateProgramParams params) async {
    final result = await _programRepository.save(params);
    switch (result) {
      case AppSuccess(:final data):
        return AppResult.success(data);
      case AppFailure<Program>(:final exception):
        return AppResult.failure(exception);
    }
  }
}
