import 'package:equatable/equatable.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/domain/entities.dart';
import 'package:sistem_admin/faculty/domain/repository.dart';

/// Params for [UpdateFacultyUseCase]
final class UpdateFacultyParams extends Equatable {
  /// Creates new [UpdateFacultyParams]
  const new(this.faculty, {required this.name});

  /// Faculty that will be updated
  final Faculty faculty;

  /// Updated name
  final String? name;

  @override
  List<Object?> get props => [faculty, name];
}

/// Use case for updating a [Faculty]
class UpdateFacultyUseCase
    implements FutureBaseUseCase<UpdateFacultyParams, Faculty> {
  /// Creates new [UpdateFacultyUseCase]
  new({required this._facultyRepository});

  final IFacultyRepository _facultyRepository;

  @override
  Future<AppResult<Faculty>> call(UpdateFacultyParams params) {
    return _facultyRepository.update(params.faculty.id, args: params);
  }
}
