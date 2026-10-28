import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
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
@LazySingleton(env: [Environment.prod])
class UpdateFacultyUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<UpdateFacultyParams, Faculty> {
  /// Creates new [UpdateFacultyUseCase]
  new({required this._facultyRepository});

  final IFacultyRepository _facultyRepository;

  @override
  Future<AppResult<Faculty>> call(UpdateFacultyParams params) async {
    logDebug(
      'start updating faculty',
      extra: {'id': params.faculty.id, 'name': params.name},
    );
    final result = await _facultyRepository.update(
      params.faculty.id,
      args: params,
    );
    switch (result) {
      case AppSuccess(:final data):
        logDebug('faculty updated');
        return AppResult.success(data);
      case AppFailure<Faculty>(:final exception):
        logDebug('faculty update failed');
        return AppResult.failure(exception);
    }
  }
}
