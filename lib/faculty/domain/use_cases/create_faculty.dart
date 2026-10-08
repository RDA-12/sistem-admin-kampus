import 'package:equatable/equatable.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/domain/entities.dart';
import 'package:sistem_admin/faculty/domain/repository.dart';

/// Params for [CreateFacultyUseCase]
final class CreateFacultyParams extends Equatable {
  /// Creates new [CreateFacultyParams]
  const new({required this.name});

  /// Name for the faculty
  final String name;

  @override
  List<Object?> get props => [name];
}

/// Use case for creating new [Faculty]
class CreateFacultyUseCase
    implements FutureBaseUseCase<CreateFacultyParams, Faculty> {
  /// Creates new [CreateFacultyUseCase]
  new({required this._facultyRepository});

  final IFacultyRepository _facultyRepository;

  /// Run creating new [Faculty]
  @override
  Future<AppResult<Faculty>> call(CreateFacultyParams params) async {
    final result = await _facultyRepository.save(name: params.name);
    switch (result) {
      case AppSuccess(:final data):
        return AppResult.success(data);
      case AppFailure<Faculty>(:final exception):
        return AppResult.failure(exception);
    }
  }
}
